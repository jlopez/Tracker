//
//  EditExerciseView.swift
//  Tracker
//
//  Created by Jesus Lopez on 2/23/24.
//

import SwiftUI
import SwiftData

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

            if !todaySets.isEmpty {
                Section("Today") {
                    ExerciseSetsView(exerciseSets: todaySets)
                }
            }

            if !previousDaySets.isEmpty {
                Section("Previous") {
                    ExerciseSetsView(exerciseSets: previousDaySets)
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

#Preview {
    let modelContainer = try! ModelContainer(for: Exercise.self, configurations: .init(isStoredInMemoryOnly: true))
    let exercise = Exercise(name: "Biceps Curl")
    modelContainer.mainContext.insert(exercise)
    exercise.exerciseSets.append(ExerciseSet(
        startedAt: .now.addingTimeInterval(-17.38),
        endedAt: .now,
        reps: 8,
        weight: 22.5))
    exercise.exerciseSets.append(ExerciseSet(
        startedAt: .now.addingTimeInterval(-132-18.11),
        endedAt: .now.addingTimeInterval(-120),
        reps: 8,
        weight: 25))
    return EditExerciseView(exercise: exercise)
        .environment(Globals())
}
