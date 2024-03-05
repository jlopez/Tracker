//
//  EditExerciseView.swift
//  Tracker
//
//  Created by Jesus Lopez on 2/23/24.
//

import SwiftUI

struct EditExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Globals.self) private var globals
    @Bindable var exercise: Exercise

    var lastSet: ExerciseSet? { exercise.exerciseSets.max { $0.endedAt ?? .distantPast < $1.endedAt ?? .distantPast } }
    var lastReps: Int { lastSet?.reps ?? 0 }
    var lastWeight: Int { lastSet?.weight ?? 0 }

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $exercise.name)
                    .textInputAutocapitalization(.words)
            }

            if let lastSet = lastSet, let endedAt = lastSet.endedAt {
                Section("Last Set") {
                    Text("Reps: \(lastSet.reps)")
                    Text("Weight: \(lastSet.weight)")
                    Text("Completed \(endedAt, style: .relative) ago")
                }
            }

            if !exercise.exerciseSets.isEmpty {
                Section("Sets") {
                    ExerciseSetsView(exerciseSets: exercise.exerciseSets)
                }
            }

            Section("Internals") {
                DatePicker("createdAt", selection: $exercise.createdAt)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Add Set", systemImage: "plus", action: addExerciseSet)
            }
        }
        .navigationTitle("Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
    }

    func addExerciseSet() {
        let exerciseSet = ExerciseSet(
            reps: lastReps,
            weight: lastWeight
        )
        exercise.exerciseSets.append(exerciseSet)
        globals.navigationPath.append(exerciseSet)
    }
}
