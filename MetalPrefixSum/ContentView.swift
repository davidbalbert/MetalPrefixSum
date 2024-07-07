//
//  ContentView.swift
//  MetalPrefixSum
//
//  Created by David Albert on 7/7/24.
//

import SwiftUI
import Metal

struct ContentView: View {
    var result: String {
        guard let data = sum.data else {
            return "[]"
        }
        var s = "["
        for (i, n) in data.enumerated() {
            s += "\(n)"
            if i < data.count-1 {
                s += ", "
            }
        }
        s += "]"
        return s
    }

    let sum = PrefixSum(device: MTLCreateSystemDefaultDevice())

    var body: some View {
        VStack {
            Text(result)
            Button("Compute") {
                sum.run()
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    ContentView()
}
