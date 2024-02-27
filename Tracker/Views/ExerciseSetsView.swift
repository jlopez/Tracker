//
//  ExerciseSetsView.swift
//  Tracker
//
//  Created by Jesus Lopez on 2/23/24.
//

import SwiftUI

struct ExerciseSetsView: View {
    @Environment(\.modelContext) private var modelContext
    let exerciseSets: [ExerciseSet]

    init(exerciseSets: [ExerciseSet]) {
        self.exerciseSets = exerciseSets.sorted { $0.startedAt ?? .distantFuture > $1.startedAt ?? .distantFuture }
    }

    var body: some View {
        ForEach(exerciseSets) { exerciseSet in
            NavigationLink(value: exerciseSet) {
                ExerciseSetRow(exerciseSet: exerciseSet)
            }
        }
        .onDelete(perform: deleteSet)
    }

    func deleteSet(offsets: IndexSet) {
        for index in offsets {
            let exerciseSet = exerciseSets[index]
            modelContext.delete(exerciseSet)
        }
    }
}
