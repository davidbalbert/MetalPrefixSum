//
//  PrefixSum.swift
//  MetalPrefixSum
//
//  Created by David Albert on 7/7/24.
//

import Metal

@Observable
class PrefixSum {
    class Shader {
        let device: MTLDevice
        let state: MTLComputePipelineState
        let queue: MTLCommandQueue

        let a: MTLBuffer
        let b: MTLBuffer
        let res: MTLBuffer

        static let bufsz: Int = 9

        init?(device: MTLDevice?) {
            guard let device else {
                return nil
            }
            self.device = device
            let library = device.makeDefaultLibrary()
            guard let f = library?.makeFunction(name: "prefix_sum") else {
                return nil
            }
            guard let state = try? device.makeComputePipelineState(function: f) else {
                return nil
            }
            self.state = state
            guard let queue = device.makeCommandQueue() else {
                return nil
            }
            self.queue = queue

            let a = device.makeBuffer(length: Self.bufsz, options: .storageModeShared)
            let b = device.makeBuffer(length: Self.bufsz, options: .storageModeShared)
            let res = device.makeBuffer(length: Self.bufsz, options: .storageModeShared)
            guard let a, let b, let res else {
                return nil
            }
            self.a = a
            self.b = b
            self.res = res

            fill(a, with: 1)
            fill(b, with: 2)
        }

        func fill(_ buffer: MTLBuffer, with val: UInt8) {
            assert(buffer.allocatedSize == Self.bufsz)

            buffer.contents().withMemoryRebound(to: UInt8.self, capacity: buffer.allocatedSize) { pointer in
                pointer.update(repeating: val, count: buffer.allocatedSize)
            }

        }

        func run(_ block: @escaping (MTLBuffer) -> Void) {
            guard let cmdbuf = queue.makeCommandBuffer() else { return }
            guard let encoder = cmdbuf.makeComputeCommandEncoder() else { return }

            encoder.setComputePipelineState(state)
            encoder.setBuffer(a, offset: 0, index: 0)
            encoder.setBuffer(b, offset: 0, index: 1)
            encoder.setBuffer(res, offset: 0, index: 2)

            let gridsz = MTLSize(width: Self.bufsz, height: 1, depth: 1)
            let tgsz = MTLSize(width: state.maxTotalThreadsPerThreadgroup, height: 1, depth: 1)
            print(gridsz, tgsz)
            encoder.dispatchThreads(gridsz, threadsPerThreadgroup: tgsz)

            encoder.endEncoding()

            cmdbuf.addCompletedHandler { [weak self] cmdbuf in
                guard let self else { return }
                block(res)
            }

            cmdbuf.commit()
        }
    }

    let shader: Shader?
    var data: Data?

    init(device: MTLDevice?) {
        self.shader = Shader(device: device)
    }

    func run() {
        shader?.run { [weak self] result in
            assert(result.allocatedSize == Shader.bufsz)
            self?.data = Data(bytesNoCopy: result.contents(), count: result.allocatedSize, deallocator: .none)
        }
    }
}
