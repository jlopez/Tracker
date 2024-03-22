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

    var previousDaySets: [ExerciseSet] {
        exercise.previousSets(from: .now)
    }

    var todaySets: [ExerciseSet] {
        exercise.sets(for: .now)
    }

    var setsDoneToday: Int {
        todaySets.count
    }

    var previousDayEquivalentSet: ExerciseSet? {
        let previousSets = previousDaySets
        guard previousSets.count > setsDoneToday else { return nil }
        return previousSets[setsDoneToday]
    }

    var nextReps: Int { previousDayEquivalentSet?.reps ?? 0 }
    var nextWeight: Double { previousDayEquivalentSet?.weight ?? 0 }

    var lastSet: ExerciseSet? { exercise.exerciseSets.max { $0.endedAt ?? .distantPast < $1.endedAt ?? .distantPast } }

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $exercise.name)
                    .textInputAutocapitalization(.words)
            }

            Button("Stats", systemImage: "chart.bar") {
                globals.navigationPath.append(Screens.stats(exercise))
            }

            if let lastSet = lastSet, let endedAt = lastSet.endedAt {
                Section("Last Set") {
                    Text("Reps: \(nextReps)")
                    Text("Weight: \(nextWeight, specifier: "%.1f")")
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
            reps: nextReps,
            weight: nextWeight
        )
        exercise.exerciseSets.append(exerciseSet)
        globals.navigationPath.append(exerciseSet)
    }
}

