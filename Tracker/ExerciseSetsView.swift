//
//  ExerciseSetsView.swift
//  Tracker
//
//  Created by Jesus Lopez on 1/31/24.
//

import SwiftUI

struct ExerciseSetsView: View {
    @Environment(\.modelContext) var modelContext
    var exercise: Exercise
    @State var showAddSet: Bool = false

    var body: some View {
        List {
            ForEach(exercise.exerciseSets) { exerciseSet in
                Text("\(exerciseSet.reps) reps at \(exerciseSet.weight) lbs")
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle(exercise.name)
        .toolbar {
            ToolbarItem {
                Button {
                    showAddSet.toggle()
                } label: {
                    Label("Add Exercise", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSet) {
            NewExerciseSetView(exercise: exercise)
                .presentationDetents([ .medium ])
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            exercise.exerciseSets.remove(atOffsets: offsets)
        }
    }
}

struct NewExerciseSetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    var exercise: Exercise
    @State private var startedAt = Date()
    @State private var autoEnd = true
    @State private var endedAt = Date()
    @State private var reps = 0
    @State private var weight = 0

    let numberFormatter: NumberFormatter = {
          let formatter = NumberFormatter()
          formatter.zeroSymbol = ""
          return formatter
     }()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Start", selection: $startedAt)
                    Toggle("Auto End", isOn: $autoEnd)
                    if !autoEnd {
                        DatePicker("End", selection: $endedAt)
                    }
                }
                Section {
                    TextField("Reps", value: $reps, formatter: numberFormatter)
                        .onSubmit(addExerciseSet)
                        .keyboardType(.numberPad)
                    TextField("Weight", value: $weight, formatter: numberFormatter)
                        .onSubmit(addExerciseSet)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("New Set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(action: addExerciseSet) {
                        Text("Add")
                    }
                    .disabled(!isValid())
                }
            }
            .onChange(of: autoEnd) { old, new in
                if !new {
                    endedAt = Date()
                }
            }
        }
    }

    func isValid() -> Bool {
        return reps != 0 && weight != 0
    }

    func addExerciseSet() {
        guard isValid() else { return }
        let exerciseSet = ExerciseSet(
            startedAt: startedAt,
            endedAt: autoEnd ? Date() : endedAt,
            reps: reps,
            weight: weight)
        exercise.exerciseSets.append(exerciseSet)
        dismiss()
    }
}

#Preview {
    let exercise = Exercise(name: "Bicep Curls")
    return NavigationStack {
        ExerciseSetsView(exercise: exercise)
            .modelContainer(for: Exercise.self, inMemory: true)
    }
}
