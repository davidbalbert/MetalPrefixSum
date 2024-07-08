//
//  PrefixSum.metal
//  MetalPrefixSum
//
//  Created by David Albert on 7/7/24.
//

#include <metal_stdlib>
using namespace metal;

[[kernel]] void
prefix_sum(const device uint8_t *a [[buffer(0)]],
           const device uint8_t *b [[buffer(1)]],
           device uint8_t *res [[buffer(2)]],
           uint i [[thread_position_in_grid]])
{
    res[i] = a[i] + b[i];
}
