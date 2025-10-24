//
//  MetalWrapper.metal
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 10/12/24.
//

#include <metal_stdlib>
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wunused-variable"

using namespace metal;

struct VertexWrapper {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexWrapper vertex_wrapper(const device float4* vertices [[buffer(0)]], uint vertexId [[vertex_id]]) {
    VertexWrapper out;
    out.position = float4(vertices[vertexId].xy, 0.0, 1.0); // Pass position
    out.texCoord = vertices[vertexId].zw;                 // Pass texture coordinates
    return out;
}

fragment float4 fragment_wrapper(VertexWrapper in [[stage_in]], texture2d<float, access::sample> texture [[texture(0)]]) {
    constexpr sampler textureSampler(coord::normalized, address::clamp_to_edge, filter::linear);
    return texture.sample(textureSampler, in.texCoord); // Outputs as-is
}
