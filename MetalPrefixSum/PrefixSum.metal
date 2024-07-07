//
//  PrefixSum.metal
//  MetalPrefixSum
//
//  Created by David Albert on 7/7/24.
//

#include <metal_stdlib>
using namespace metal;

kernel void
prefix_sum(device const uint8_t *a, device const uint8_t *b, device uint8_t *res, uint i [[thread_position_in_grid]])
{
    res[i] = a[i] + b[i];
}
