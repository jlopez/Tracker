//
//  PoundsPerSecondView.swift
//  Tracker
//
//  Created by Jesus Lopez on 2/26/24.
//

import SwiftUI

struct PoundsPerSecondView: View {
    let poundsPerSecond: Double?

    var body: some View {
        let pps = poundsPerSecond ?? 0
        let decimals = pps < 10 ? 1 : 0
        let hue = min(max(0, pps / 100), 1) / 3
        Text(pps, format: .number.precision(.fractionLength(decimals)))
            .foregroundColor(Color(hue: hue, saturation: 1, brightness: 1))
            .fontWeight(.bold)
            .font(.title3)
    }
}

#Preview {
    List {
        HStack {
            PoundsPerSecondView(poundsPerSecond: 10)
            PoundsPerSecondView(poundsPerSecond: 50)
            PoundsPerSecondView(poundsPerSecond: 90)
        }
    }
}
