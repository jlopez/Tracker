//
//  RestTimerView.swift
//  Tracker
//
//  Created by Jesus Lopez on 2/2/24.
//

import SwiftUI

struct RestTimerView: View {
    let referenceDate: Date
    @State private var now = Date()

    var secondsElapsed: Int { Int(now.timeIntervalSince(referenceDate)) }
    var timerMinutes: Int { Int(secondsElapsed / 60) }
    var timerSeconds: Int { Int(secondsElapsed) % 60 }

    var body: some View {
        if secondsElapsed < 120 {
            Text("\(timerMinutes):\(timerSeconds, specifier: "%02d")")
                .task(id: now, reset)
        }
//            .font(.largeTitle)
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 30)
//            .background(.accent)
    }

    @Sendable
    func reset() async {
        let targetDate = referenceDate.addingTimeInterval(TimeInterval(secondsElapsed + 1))
        let delay = max(0, targetDate.timeIntervalSince(Date()))
        let delayInNanoseconds = UInt64(delay * 1_000_000_000)
        try? await Task.sleep(nanoseconds: delayInNanoseconds)
        now = Date()
    }
}

#Preview {
    ZStack {
        Text("Hello, World")
        VStack {
            Spacer()
            RestTimerView(referenceDate: .now)
        }
    }
}
