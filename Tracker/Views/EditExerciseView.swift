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

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $exercise.name)
                    .textInputAutocapitalization(.words)
            }

            Section("Internals") {
                DatePicker("createdAt", selection: $exercise.createdAt)
                TextField("Last Reps", value: $exercise.lastReps, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                TextField("Last Weight", value: $exercise.lastReps, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
            }

            if !exercise.exerciseSets.isEmpty {
                Section("Sets") {
                    ExerciseSetsView(exerciseSets: exercise.exerciseSets)
                }
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
            reps: exercise.lastReps,
            weight: exercise.lastWeight
        )
        exercise.exerciseSets.append(exerciseSet)
        globals.navigationPath.append(exerciseSet)
    }
}
