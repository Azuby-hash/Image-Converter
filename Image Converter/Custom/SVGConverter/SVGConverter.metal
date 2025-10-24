//
//  SVGConverter.metal
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 20/10/25.
//

#include <metal_stdlib>
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wunused-variable"

using namespace metal;

kernel void SVGFilter(
    constant float& low [[ buffer(0) ]],
    constant float& high [[ buffer(1) ]],
    texture2d<float, access::read>  inputTexture  [[ texture(2) ]],
    texture2d<float, access::write> outputTexture [[ texture(3) ]],
    uint2 gid [[ thread_position_in_grid ]]) {
    
    float4 rgba = inputTexture.read(gid);
    float color = 0.299 * rgba.r + 0.587 * rgba.g + 0.114 * rgba.b;
    color = color > low && color < high ? 0 : 1;
    
    outputTexture.write(float4(float3(color), 1), gid);
}
