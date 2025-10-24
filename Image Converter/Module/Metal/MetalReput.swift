//
//  MetalReput.swift
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 10/12/24.
//

import UIKit
import Metal
import MetalKit

class MetalReput {
    private let buffer: MTLBuffer
    
    init(buffer: MTLBuffer) {
        self.buffer = buffer
    }
    
    func getBuffer() -> MTLBuffer {
        return buffer
    }
    
    func encode(to computeEncoder: MTLComputeCommandEncoder, pixelFormat: MTLPixelFormat?, device: MTLDevice?, at index: Int) {
        computeEncoder.setBuffer(buffer, offset: 0, index: index)
    }
}
