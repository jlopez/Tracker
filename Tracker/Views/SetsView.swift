//
//  SetsView.swift
//  Tracker
//
//  Created by Jesus Lopez on 2/23/24.
//

import SwiftUI

struct SetsView: View {
    let today: [ExerciseSet]?
    let before: [ExerciseSet]?

    init(exerciseSets: [ExerciseSet]) {
        let today = Calendar.current.startOfDay(for: .now)
        let groupings = Dictionary(grouping: exerciseSets) {
            Calendar.current.startOfDay(for: $0.startedAt ?? .distantFuture) >= today
        }
        self.today = groupings[true]?.sorted { $0.startedAt ?? .distantFuture > $1.startedAt ?? .distantFuture }
        self.before = groupings[false]?.sorted { $0.startedAt ?? .distantFuture > $1.startedAt ?? .distantFuture }
    }

    var body: some View {
        if let today = today {
            Section("Today") {
                ForEach(today) { exerciseSet in
                    ExerciseSetRow(exerciseSet: exerciseSet)
                }
            }
        }
        if let before = before {
            Section("Previous Days") {
                ForEach(before) { exerciseSet in
                    ExerciseSetRow(exerciseSet: exerciseSet)
                }
            }
        }
    }
}
