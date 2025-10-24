//
//  MetalInput.swift
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 10/12/24.
//

import UIKit
import Metal
import MetalKit

typealias Float2 = (Float, Float)
typealias Float3 = (Float, Float, Float)
typealias Float4 = (Float, Float, Float, Float)

typealias Float2x2 = ((Float, Float), (Float, Float))
typealias Float2x3 = ((Float, Float, Float), (Float, Float, Float))
typealias Float2x4 = ((Float, Float, Float, Float), (Float, Float, Float, Float))
typealias Float3x2 = ((Float, Float), (Float, Float), (Float, Float))
typealias Float3x3 = ((Float, Float, Float), (Float, Float, Float), (Float, Float, Float))
typealias Float3x4 = ((Float, Float, Float, Float), (Float, Float, Float, Float), (Float, Float, Float, Float))
typealias Float4x2 = ((Float, Float), (Float, Float), (Float, Float), (Float, Float))
typealias Float4x3 = ((Float, Float, Float), (Float, Float, Float), (Float, Float, Float), (Float, Float, Float))
typealias Float4x4 = ((Float, Float, Float, Float), (Float, Float, Float, Float), (Float, Float, Float, Float), (Float, Float, Float, Float))

typealias Int2 = (Int, Int)
typealias Int3 = (Int, Int, Int)
typealias Int4 = (Int, Int, Int, Int)

/**
 Input for metal
 */
class MetalInput {
    private var ciImage: CIImage?
    private var texture: MTLTexture?
    private var size: CGSize?
    
    private var float: Float?
    private var floats: [Float]?
    private var float2: Float2?
    private var float2s: [Float2]?
    private var float3: Float3?
    private var float3s: [Float3]?
    private var float4: Float4?
    private var float4s: [Float4]?
    private var float2x2: Float2x2?
    private var float2x2s: [Float2x2]?
    private var float2x3: Float2x3?
    private var float2x3s: [Float2x3]?
    private var float2x4: Float2x4?
    private var float2x4s: [Float2x4]?
    private var float3x2: Float3x2?
    private var float3x2s: [Float3x2]?
    private var float3x3: Float3x3?
    private var float3x3s: [Float3x3]?
    private var float3x4: Float3x4?
    private var float3x4s: [Float3x4]?
    private var float4x2: Float4x2?
    private var float4x2s: [Float4x2]?
    private var float4x3: Float4x3?
    private var float4x3s: [Float4x3]?
    private var float4x4: Float4x4?
    private var float4x4s: [Float4x4]?
    
    private var int: Int?
    private var ints: [Int]?
    private var int2: Int2?
    private var int2s: [Int2]?
    private var int3: Int3?
    private var int3s: [Int3]?
    private var int4: Int4?
    private var int4s: [Int4]?
    
    private var bool: Bool?
    private var bools: [Bool]?
    
    init(ciImage: CIImage) {
        self.ciImage = ciImage
    }
    
    init(texture: MTLTexture, size: CGSize) {
        self.texture = texture
        self.size = size
    }
    
    init(point: CGPoint) {
        self.float2 = (Float(point.x), Float(point.y))
    }
    
    init(points: [CGPoint]) {
        self.float2s = points.map({ (Float($0.x), Float($0.y)) })
    }
    
    init(point2: (CGPoint, CGPoint)) {
        self.float2x2 = ((Float(point2.0.x), Float(point2.0.y)),
                         (Float(point2.1.x), Float(point2.1.y)))
    }
    
    init(point2s: [(CGPoint, CGPoint)]) {
        self.float2x2s = point2s.map({ ((Float($0.0.x), Float($0.0.y)),
                                        (Float($0.1.x), Float($0.1.y))) })
    }
    
    init(point3: (CGPoint, CGPoint, CGPoint)) {
        self.float3x2 = ((Float(point3.0.x), Float(point3.0.y)),
                         (Float(point3.1.x), Float(point3.1.y)),
                         (Float(point3.2.x), Float(point3.2.y)))
    }
    
    init(point3s: [(CGPoint, CGPoint, CGPoint)]) {
        self.float3x2s = point3s.map({ ((Float($0.0.x), Float($0.0.y)),
                                        (Float($0.1.x), Float($0.1.y)),
                                        (Float($0.2.x), Float($0.2.y))) })
    }
    
    init(point4: (CGPoint, CGPoint, CGPoint, CGPoint)) {
        self.float4x2 = ((Float(point4.0.x), Float(point4.0.y)),
                         (Float(point4.1.x), Float(point4.1.y)),
                         (Float(point4.2.x), Float(point4.2.y)),
                         (Float(point4.3.x), Float(point4.3.y)))
    }
    
    init(point4s: [(CGPoint, CGPoint, CGPoint, CGPoint)]) {
        self.float4x2s = point4s.map({ ((Float($0.0.x), Float($0.0.y)),
                                        (Float($0.1.x), Float($0.1.y)),
                                        (Float($0.2.x), Float($0.2.y)),
                                        (Float($0.3.x), Float($0.3.y))) })
    }
    
    init(size: CGSize) {
        self.float2 = (Float(size.width), Float(size.height))
    }
    
    init(sizes: [CGSize]) {
        self.float2s = sizes.map({ (Float($0.width), Float($0.height)) })
    }
    
    init(size2: (CGSize, CGSize)) {
        self.float2x2 = ((Float(size2.0.width), Float(size2.0.height)),
                         (Float(size2.1.width), Float(size2.1.height)))
    }
    
    init(size2s: [(CGSize, CGSize)]) {
        self.float2x2s = size2s.map({ ((Float($0.0.width), Float($0.0.height)),
                                       (Float($0.1.width), Float($0.1.height))) })
    }
    
    init(size3: (CGSize, CGSize, CGSize)) {
        self.float3x2 = ((Float(size3.0.width), Float(size3.0.height)),
                         (Float(size3.1.width), Float(size3.1.height)),
                         (Float(size3.2.width), Float(size3.2.height)))
    }
    
    init(size3s: [(CGSize, CGSize, CGSize)]) {
        self.float3x2s = size3s.map({ ((Float($0.0.width), Float($0.0.height)),
                                       (Float($0.1.width), Float($0.1.height)),
                                       (Float($0.2.width), Float($0.2.height))) })
    }
    
    init(size4: (CGSize, CGSize, CGSize, CGSize)) {
        self.float4x2 = ((Float(size4.0.width), Float(size4.0.height)),
                         (Float(size4.1.width), Float(size4.1.height)),
                         (Float(size4.2.width), Float(size4.2.height)),
                         (Float(size4.3.width), Float(size4.3.height)))
    }
    
    init(size4s: [(CGSize, CGSize, CGSize, CGSize)]) {
        self.float4x2s = size4s.map({ ((Float($0.0.width), Float($0.0.height)),
                                       (Float($0.1.width), Float($0.1.height)),
                                       (Float($0.2.width), Float($0.2.height)),
                                       (Float($0.3.width), Float($0.3.height))) })
    }
    
    init(rect: CGRect) {
        self.float4 = (Float(rect.minX), Float(rect.minY), Float(rect.width), Float(rect.height))
    }
    
    init(rects: [CGRect]) {
        self.float4s = rects.map({ (Float($0.minX), Float($0.minY), Float($0.width), Float($0.height)) })
    }
    
    init(rect2: (CGRect, CGRect)) {
        self.float2x4 = ((Float(rect2.0.minX), Float(rect2.0.minY), Float(rect2.0.width), Float(rect2.0.height)),
                         (Float(rect2.1.minX), Float(rect2.1.minY), Float(rect2.1.width), Float(rect2.1.height)))
    }
    
    init(rect2s: [(CGRect, CGRect)]) {
        self.float2x4s = rect2s.map({ ((Float($0.0.minX), Float($0.0.minY), Float($0.0.width), Float($0.0.height)),
                                       (Float($0.1.minX), Float($0.1.minY), Float($0.1.width), Float($0.1.height))) })
    }
    
    init(rect3: (CGRect, CGRect, CGRect)) {
        self.float3x4 = ((Float(rect3.0.minX), Float(rect3.0.minY), Float(rect3.0.width), Float(rect3.0.height)),
                         (Float(rect3.1.minX), Float(rect3.1.minY), Float(rect3.1.width), Float(rect3.1.height)),
                         (Float(rect3.2.minX), Float(rect3.2.minY), Float(rect3.2.width), Float(rect3.2.height)))
    }
    
    init(rect3s: [(CGRect, CGRect, CGRect)]) {
        self.float3x4s = rect3s.map({ ((Float($0.0.minX), Float($0.0.minY), Float($0.0.width), Float($0.0.height)),
                                       (Float($0.1.minX), Float($0.1.minY), Float($0.1.width), Float($0.1.height)),
                                       (Float($0.2.minX), Float($0.2.minY), Float($0.2.width), Float($0.2.height))) })
    }
    
    init(rect4: (CGRect, CGRect, CGRect, CGRect)) {
        self.float4x4 = ((Float(rect4.0.minX), Float(rect4.0.minY), Float(rect4.0.width), Float(rect4.0.height)),
                         (Float(rect4.1.minX), Float(rect4.1.minY), Float(rect4.1.width), Float(rect4.1.height)),
                         (Float(rect4.2.minX), Float(rect4.2.minY), Float(rect4.2.width), Float(rect4.2.height)),
                         (Float(rect4.3.minX), Float(rect4.3.minY), Float(rect4.3.width), Float(rect4.3.height)))
    }
    
    init(rect4s: [(CGRect, CGRect, CGRect, CGRect)]) {
        self.float4x4s = rect4s.map({ rect in
            let _0 = (Float(rect.0.minX), Float(rect.0.minY), Float(rect.0.width), Float(rect.0.height))
            let _1 = (Float(rect.1.minX), Float(rect.1.minY), Float(rect.1.width), Float(rect.1.height))
            let _2 = (Float(rect.2.minX), Float(rect.2.minY), Float(rect.2.width), Float(rect.2.height))
            let _3 = (Float(rect.3.minX), Float(rect.3.minY), Float(rect.3.width), Float(rect.3.height))
            
            return (_0, _1, _2, _3)
        })
    }
    
    init(float: CGFloat) {
        self.float = Float(float)
    }
    
    init(floats: [CGFloat]) {
        self.floats = floats.map({ Float($0) })
    }
    
    init(float: Float) {
        self.float = float
    }
    
    init(floats: [Float]) {
        self.floats = floats
    }
    
    init(float2: Float2) {
        self.float2 = float2
    }
    
    init(float2s: [Float2]) {
        self.float2s = float2s
    }
    
    init(float3: Float3) {
        self.float3 = float3
    }
    
    init(float3s: [Float3]) {
        self.float3s = float3s
    }
    
    init(float4: Float4) {
        self.float4 = float4
    }
    
    init(float4s: [Float4]) {
        self.float4s = float4s
    }
    
    init(float2x2: Float2x2) {
        self.float2x2 = float2x2
    }
    
    init(float2x2s: [Float2x2]) {
        self.float2x2s = float2x2s
    }
    
    init(float2x3: Float2x3) {
        self.float2x3 = float2x3
    }
    
    init(float2x3s: [Float2x3]) {
        self.float2x3s = float2x3s
    }
    
    init(float2x4: Float2x4) {
        self.float2x4 = float2x4
    }
    
    init(float2x4s: [Float2x4]) {
        self.float2x4s = float2x4s
    }
    
    init(float3x2: Float3x2) {
        self.float3x2 = float3x2
    }
    
    init(float3x2s: [Float3x2]) {
        self.float3x2s = float3x2s
    }
    
    init(float3x3: Float3x3) {
        self.float3x3 = float3x3
    }
    
    init(float3x3s: [Float3x3]) {
        self.float3x3s = float3x3s
    }
    
    init(float3x4: Float3x4) {
        self.float3x4 = float3x4
    }
    
    init(float3x4s: [Float3x4]) {
        self.float3x4s = float3x4s
    }
    
    init(float4x2: Float4x2) {
        self.float4x2 = float4x2
    }
    
    init(float4x2s: [Float4x2]) {
        self.float4x2s = float4x2s
    }
    
    init(float4x3: Float4x3) {
        self.float4x3 = float4x3
    }
    
    init(float4x3s: [Float4x3]) {
        self.float4x3s = float4x3s
    }
    
    init(float4x4: Float4x4) {
        self.float4x4 = float4x4
    }
    
    init(float4x4s: [Float4x4]) {
        self.float4x4s = float4x4s
    }
    
    init(int: Int) {
        self.int = int
    }
    
    init(ints: [Int]) {
        self.ints = ints
    }
    
    init(int2: Int2) {
        self.int2 = int2
    }
    
    init(int2s: [Int2]) {
        self.int2s = int2s
    }
    
    init(int3: Int3) {
        self.int3 = int3
    }
    
    init(int3s: [Int3]) {
        self.int3s = int3s
    }
    
    init(int4: Int4) {
        self.int4 = int4
    }
    
    init(int4s: [Int4]) {
        self.int4s = int4s
    }
    
    init(bool: Bool) {
        self.bool = bool
    }
    
    init(bools: [Bool]) {
        self.bools = bools
    }
    
    func getCIImage() -> CIImage? {
        return ciImage
    }
    
    func getTexture() -> MTLTexture? {
        return texture
    }
    
    func getTextureSize() -> CGSize? {
        return size
    }
    
    func getPoint() -> CGPoint? {
        if let float2 = float2 {
            return CGPoint(x: CGFloat(float2.0), y: CGFloat(float2.1))
        }
        
        return nil
    }
    
    func getPoints() -> [CGPoint]? {
        if let float2s = float2s {
            return float2s.map({ CGPoint(x: CGFloat($0.0), y: CGFloat($0.1)) })
        }
        
        return nil
    }
    
    func getSize() -> CGSize? {
        if let float2 = float2 {
            return CGSize(width: CGFloat(float2.0), height: CGFloat(float2.1))
        }
        
        return nil
    }
    
    func getSizes() -> [CGSize]? {
        if let float2s = float2s {
            return float2s.map({ CGSize(width: CGFloat($0.0), height: CGFloat($0.1)) })
        }
        
        return nil
    }
    
    func getRect() -> CGRect? {
        if let float4 = float4 {
            return CGRect(x: CGFloat(float4.0), y: CGFloat(float4.1), width: CGFloat(float4.2), height: CGFloat(float4.3))
        }
        
        return nil
    }
    
    func getRects() -> [CGRect]? {
        if let float4s = float4s {
            return float4s.map({ CGRect(x: CGFloat($0.0), y: CGFloat($0.1), width: CGFloat($0.2), height: CGFloat($0.3)) })
        }
        
        return nil
    }
    
    func getCGFloat() -> CGFloat? {
        if let float = float {
            return CGFloat(float)
        }
        
        return nil
    }
    
    func getCGFloats() -> [CGFloat]? {
        if let floats = floats {
            return floats.map({ CGFloat($0) })
        }
        
        return nil
    }
    
    func getFloat() -> Float? {
        return float
    }
    
    func getFloats() -> [Float]? {
        return floats
    }
    
    func getFloat2() -> Float2? {
        return float2
    }
    
    func getFloat2s() -> [Float2]? {
        return float2s
    }
    
    func getFloat3() -> Float3? {
        return float3
    }
    
    func getFloat3s() -> [Float3]? {
        return float3s
    }
    
    func getFloat4() -> Float4? {
        return float4
    }
    
    func getFloat4s() -> [Float4]? {
        return float4s
    }
    
    func getFloat2x2() -> Float2x2? {
        return float2x2
    }
    
    func getFloat2x2s() -> [Float2x2]? {
        return float2x2s
    }
    
    func getFloat2x3() -> Float2x3? {
        return float2x3
    }
    
    func getFloat2x3s() -> [Float2x3]? {
        return float2x3s
    }
    
    func getFloat2x4() -> Float2x4? {
        return float2x4
    }
    
    func getFloat2x4s() -> [Float2x4]? {
        return float2x4s
    }
    
    func getFloat3x2() -> Float3x2? {
        return float3x2
    }
    
    func getFloat3x2s() -> [Float3x2]? {
        return float3x2s
    }
    
    func getFloat3x3() -> Float3x3? {
        return float3x3
    }
    
    func getFloat3x3s() -> [Float3x3]? {
        return float3x3s
    }
    
    func getFloat3x4() -> Float3x4? {
        return float3x4
    }
    
    func getFloat3x4s() -> [Float3x4]? {
        return float3x4s
    }
    
    func getFloat4x2() -> Float4x2? {
        return float4x2
    }
    
    func getFloat4x2s() -> [Float4x2]? {
        return float4x2s
    }
    
    func getFloat4x3() -> Float4x3? {
        return float4x3
    }
    
    func getFloat4x3s() -> [Float4x3]? {
        return float4x3s
    }
    
    func getFloat4x4() -> Float4x4? {
        return float4x4
    }
    
    func getFloat4x4s() -> [Float4x4]? {
        return float4x4s
    }
    
    func getInt() -> Int? {
        return int
    }
    
    func getInts() -> [Int]? {
        return ints
    }
    
    func getInt2() -> Int2? {
        return int2
    }
    
    func getInt2s() -> [Int2]? {
        return int2s
    }
    
    func getInt3() -> Int3? {
        return int3
    }
    
    func getInt3s() -> [Int3]? {
        return int3s
    }
    
    func getInt4() -> Int4? {
        return int4
    }
    
    func getInt4s() -> [Int4]? {
        return int4s
    }
    
    func getBool() -> Bool? {
        return bool
    }
    
    func getBools() -> [Bool]? {
        return bools
    }
    
    func texture(device: MTLDevice?, pixelFormat: MTLPixelFormat) -> MTLTexture? {
        return texture ?? __texture(from: ciImage, pixelFormat: pixelFormat, device: device)
    }
    
    func encode(to computeEncoder: MTLComputeCommandEncoder, pixelFormat: MTLPixelFormat?, device: MTLDevice?, at index: Int) {
        if let pixelFormat = pixelFormat,
           texture != nil || ciImage != nil,
           let texture = texture ?? __texture(from: ciImage, pixelFormat: pixelFormat, device: device) {
            computeEncoder.setTexture(texture, index: index)
        }
        
        if let float = float {
            let buffer = device?.makeBuffer(bytes: [float], length: MemoryLayout<Float>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let floats = floats {
            let buffer = device?.makeBuffer(bytes: floats, length: MemoryLayout<Float>.stride * floats.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float2 = float2 {
            let buffer = device?.makeBuffer(bytes: [float2], length: MemoryLayout<Float2>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float2s = float2s {
            let buffer = device?.makeBuffer(bytes: float2s, length: MemoryLayout<Float2>.stride * float2s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float3 = float3 {
            let buffer = device?.makeBuffer(bytes: [float3], length: MemoryLayout<Float3>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float3s = float3s {
            let buffer = device?.makeBuffer(bytes: float3s, length: MemoryLayout<Float3>.stride * float3s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float4 = float4 {
            let buffer = device?.makeBuffer(bytes: [float4], length: MemoryLayout<Float4>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float4s = float4s {
            let buffer = device?.makeBuffer(bytes: float4s, length: MemoryLayout<Float4>.stride * float4s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float2x2 = float2x2 {
            let buffer = device?.makeBuffer(bytes: [float2x2], length: MemoryLayout<Float2x2>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float2x2s = float2x2s {
            let buffer = device?.makeBuffer(bytes: float2x2s, length: MemoryLayout<Float2x2>.stride * float2x2s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float2x3 = float2x3 {
            let buffer = device?.makeBuffer(bytes: [float2x3], length: MemoryLayout<Float2x3>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float2x3s = float2x3s {
            let buffer = device?.makeBuffer(bytes: float2x3s, length: MemoryLayout<Float2x3>.stride * float2x3s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float2x4 = float2x4 {
            let buffer = device?.makeBuffer(bytes: [float2x4], length: MemoryLayout<Float2x4>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float2x4s = float2x4s {
            let buffer = device?.makeBuffer(bytes: float2x4s, length: MemoryLayout<Float2x4>.stride * float2x4s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float3x2 = float3x2 {
            let buffer = device?.makeBuffer(bytes: [float3x2], length: MemoryLayout<Float3x2>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float3x2s = float3x2s {
            let buffer = device?.makeBuffer(bytes: float3x2s, length: MemoryLayout<Float3x2>.stride * float3x2s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float3x3 = float3x3 {
            let buffer = device?.makeBuffer(bytes: [float3x3], length: MemoryLayout<Float3x3>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float3x3s = float3x3s {
            let buffer = device?.makeBuffer(bytes: float3x3s, length: MemoryLayout<Float3x3>.stride * float3x3s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float3x4 = float3x4 {
            let buffer = device?.makeBuffer(bytes: [float3x4], length: MemoryLayout<Float3x4>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float3x4s = float3x4s {
            let buffer = device?.makeBuffer(bytes: float3x4s, length: MemoryLayout<Float3x4>.stride * float3x4s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float4x2 = float4x2 {
            let buffer = device?.makeBuffer(bytes: [float4x2], length: MemoryLayout<Float4x2>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float4x2s = float4x2s {
            let buffer = device?.makeBuffer(bytes: float4x2s, length: MemoryLayout<Float4x2>.stride * float4x2s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float4x3 = float4x3 {
            let buffer = device?.makeBuffer(bytes: [float4x3], length: MemoryLayout<Float4x3>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float4x3s = float4x3s {
            let buffer = device?.makeBuffer(bytes: float4x3s, length: MemoryLayout<Float4x3>.stride * float4x3s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float4x4 = float4x4 {
            let buffer = device?.makeBuffer(bytes: [float4x4], length: MemoryLayout<Float4x4>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let float4x4s = float4x4s {
            let buffer = device?.makeBuffer(bytes: float4x4s, length: MemoryLayout<Float4x4>.stride * float4x4s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let int = int {
            let buffer = device?.makeBuffer(bytes: [int], length: MemoryLayout<Int>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let ints = ints {
            let buffer = device?.makeBuffer(bytes: ints, length: MemoryLayout<Int>.stride * ints.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let int2 = int2 {
            let buffer = device?.makeBuffer(bytes: [int2], length: MemoryLayout<Int2>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let int2s = int2s {
            let buffer = device?.makeBuffer(bytes: int2s, length: MemoryLayout<Int2>.stride * int2s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let int3 = int3 {
            let buffer = device?.makeBuffer(bytes: [int3], length: MemoryLayout<Int3>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let int3s = int3s {
            let buffer = device?.makeBuffer(bytes: int3s, length: MemoryLayout<Int3>.stride * int3s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let int4 = int4 {
            let buffer = device?.makeBuffer(bytes: [int4], length: MemoryLayout<Int4>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let int4s = int4s {
            let buffer = device?.makeBuffer(bytes: int4s, length: MemoryLayout<Int4>.stride * int4s.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let bool = bool {
            let buffer = device?.makeBuffer(bytes: [bool], length: MemoryLayout<Bool>.stride, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }

        if let bools = bools {
            let buffer = device?.makeBuffer(bytes: bools, length: MemoryLayout<Bool>.stride * bools.count, options: [])
            computeEncoder.setBuffer(buffer, offset: 0, index: index)
        }
    }
}

extension MetalInput {
    private func __texture(from ciImage: CIImage?, pixelFormat: MTLPixelFormat, device: MTLDevice?) -> MTLTexture? {
        guard let device = device, let ciImage = ciImage else {
            print("Failed due to no device")
            return nil
        }
        
        let context = CIContext(mtlDevice: device)
        let width = Int(ciImage.extent.width)
        let height = Int(ciImage.extent.height)

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: width, height: height, mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        
        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            print("Failed to create Metal texture.")
            return nil
        }
        
        let ciTexture = ciImage.transformed(by: CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -ciImage.extent.height))
        context.render(ciTexture, to: texture, commandBuffer: nil, bounds: ciImage.extent, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        return texture
    }
}
