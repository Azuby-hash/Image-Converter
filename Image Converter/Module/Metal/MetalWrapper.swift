//
//  Metal.swift
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 10/12/24.
//

import UIKit
import Metal
import MetalKit

/**
 - Step1: Create a .metal
 ```
 #include <metal_stdlib>
 #pragma clang diagnostic ignored "-Wdeprecated-declarations"
 #pragma clang diagnostic ignored "-Wunused-variable"

 using namespace metal;

 kernel void MetalExample(const device float& number [[buffer(0)]],   // For number input (Float)
                          const device float* numbers [[buffer(1)]],   // For array input (Float)
                          texture2d<half, access::read> inputTexture [[texture(2)]],   // For image input (CIImage/MTLTexture)
                          texture2d<half, access::write> outputTexture [[texture(3)]],   // Must have, only, destinition
                          uint2 gid [[thread_position_in_grid]])   // Must have, only, provide position
 {
    outputTexture.write(inputTexture.read(gid), gid);
 }
 ```
 - Step2: Init MetalWrapper
 ```
 wrapper = MetalWrapper(funcName: "MetalExample")
 ```
 - Step3: Pipeline to MTKView (Optional for real-time preview)
 ```
 wrapper?.pipeline(to: <your MTKView>) // for preview
 ```
 - Step4: Compute func with input
 ```
 wrapper?.compute(inputs: [
    .init(float: 1),
    .init(floats: [1]),
    .init(ciImage: inputImage)
 ], inputSize: <inputSize>, outputSize: <expectOutputSize>)
 ```
 - Step5: Get output (Optional if u want to get image, not need if use pipeline to MTKView)
 ```
 <Your UIImageView>.image = wrapper?.output().makeImage()
 ```
 
 - Important: All .metal files are connected, not need to read file name
 */
class MetalWrapper: NSObject {
    private weak var mtkView: MTKView?
    private var commandQueue: MTLCommandQueue?
    private var computePipelineState: MTLComputePipelineState?
    private var renderPipelineState: MTLRenderPipelineState?
    
    private var output: MetalOutput?
    
    private(set) var device: MTLDevice?
    private(set) var pixelFormat: MTLPixelFormat
    
    init(funcName: String, vertexName: String? = nil, fragmentName: String? = nil, pixelFormat: MTLPixelFormat) {
        self.pixelFormat = pixelFormat

        super.init()
        
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device.")
            return
        }
        
        self.device = metalDevice
        
        guard let commandQueue = metalDevice.makeCommandQueue() else {
            print("Unable to create a Metal command queue.")
            return
        }
        self.commandQueue = commandQueue
        
        do {
            let defaultLibrary = try metalDevice.makeDefaultLibrary(bundle: .main)
            guard let kernelFunction = defaultLibrary.makeFunction(name: funcName) else {
                print("Failed to find the compute function `\(funcName)` in the Metal library.")
                return
            }
            self.computePipelineState = try metalDevice.makeComputePipelineState(function: kernelFunction)

            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = defaultLibrary.makeFunction(name: vertexName ?? "vertex_wrapper")
            descriptor.fragmentFunction = defaultLibrary.makeFunction(name: fragmentName ?? "fragment_wrapper")
            descriptor.colorAttachments[0].pixelFormat = pixelFormat // Ensure this matches MTKView
            descriptor.depthAttachmentPixelFormat = .depth32Float
            descriptor.label = "Texture Render Pipeline"

            self.renderPipelineState = try metalDevice.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print("Failed to initialize the Metal pipeline state: \(error).")
        }
    }
    
    func setFuncName(_ name: String) {
        guard let device = device else {
            print("Metal is not supported on this device.")
            return
        }
        
        let defaultLibrary = try? device.makeDefaultLibrary(bundle: .main)
        guard let kernelFunction = defaultLibrary?.makeFunction(name: name) else {
            print("Failed to find the compute function `\(name)` in the Metal library.")
            return
        }
        
        self.computePipelineState = try? device.makeComputePipelineState(function: kernelFunction)
    }
    
    /**
     Pipeline to MTKView to show content from **compute** in real-time
     */
    func pipeline(to mtkView: MTKView) {
        self.mtkView = mtkView
        self.mtkView?.device = device
        self.mtkView?.colorPixelFormat = pixelFormat
        self.mtkView?.delegate = self
    }
    
    /**
     Compute func with inputs
     */
    func compute(inputs: [MetalInput], reputs: [MetalReput], inputSize: CGSize, outputSize: CGSize) {
        // Create an output texture
        let outputTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                                               width: Int(outputSize.width),
                                                                               height: Int(outputSize.height),
                                                                               mipmapped: false)
        outputTextureDescriptor.usage = [.renderTarget, .shaderWrite, .shaderRead]
        guard let outputTexture = device?.makeTexture(descriptor: outputTextureDescriptor) else {
            print("Failed to create output texture.")
            return
        }
        
        self.output = .init(texture: outputTexture)
        
        guard let computePipelineState = computePipelineState,
              let commandBuffer = commandQueue?.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            print("Failed to create command buffer or compute encoder.")
            return
        }

        computeEncoder.setComputePipelineState(computePipelineState)
        
        for (index, input) in inputs.enumerated() {
            input.encode(to: computeEncoder, pixelFormat: pixelFormat, device: device, at: index)
        }
        
        for (index, reput) in reputs.enumerated() {
            reput.encode(to: computeEncoder, pixelFormat: pixelFormat, device: device, at: index + inputs.count)
        }
        
        if let outputTexture = self.output?.getTexture() {
            computeEncoder.setTexture(outputTexture, index: inputs.count + reputs.count)
        }

        // Configure thread groups and threadgroup sizes
        let threadGroupSize = MTLSize(width: 16, height: 16, depth: 1)
        let threadGroups = MTLSize(width: (Int(inputSize.width) + threadGroupSize.width - 1) / threadGroupSize.width,
                                   height: (Int(inputSize.height) + threadGroupSize.height - 1) / threadGroupSize.height,
                                   depth: 1)

        computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
        computeEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    /**
     Get output, need **compute** first
     */
    func getOutput() -> MetalOutput? {
        return output
    }
}

extension MetalWrapper: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle view size change if necessary
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let outputTexture = output?.getTexture(),
              let renderPipelineState = renderPipelineState,
              let commandBuffer = commandQueue?.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        view.drawableSize = CGSize(width: outputTexture.width, height: outputTexture.height)
        
        let quadVertices: [Float] = [
            -1.0, -1.0, 0.0, 1.0, // Bottom-left
             1.0, -1.0, 1.0, 1.0, // Bottom-right
            -1.0,  1.0, 0.0, 0.0, // Top-left
             1.0,  1.0, 1.0, 0.0  // Top-right
        ]
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(renderPipelineState)
        renderEncoder?.setVertexBytes(quadVertices, length: MemoryLayout<Float>.stride * quadVertices.count, index: 0)
        renderEncoder?.setFragmentTexture(outputTexture, index: 0)
        renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder?.endEncoding()
        
        view.backgroundColor = .clear
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
