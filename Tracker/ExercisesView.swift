//
//  ContentView.swift
//  Tracker
//
//  Created by Jesus Lopez on 1/31/24.
//

import SwiftUI
import SwiftData

struct ExercisesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    @State private var showAddExercise: Bool = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(exercises) { exercise in
                    NavigationLink {
                        ExerciseSetsView(exercise: exercise)
                            .navigationBarTitleDisplayMode(.large)
                    } label: {
                        Text(exercise.name)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        showAddExercise.toggle()
                    } label: {
                        Label("Add Exercise", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Exercises")
        } detail: {
            Text("Select an exercise")
        }
        .sheet(isPresented: $showAddExercise) {
            NewExerciseView()
                .presentationDetents([ .medium ])
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(exercises[index])
            }
        }
    }
}

struct NewExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .onSubmit(addExercise)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("New Exercise")
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
                    Button(action: addExercise) {
                        Text("Add")
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    func addExercise() {
        guard !name.isEmpty else { return }
        let newExercise = Exercise(name: name)
        modelContext.insert(newExercise)
        dismiss()
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: Exercise.self, configurations: .init(isStoredInMemoryOnly: true))
    let exercise = Exercise(name: "Biceps Curl", lastReps: 8, lastWeight: 10)
    modelContainer.mainContext.insert(exercise)
    let endedAt = Date()
    let startedAt = endedAt.addingTimeInterval(-17.38)
    let exerciseSet = ExerciseSet(startedAt: startedAt, endedAt: endedAt, reps: 8, weight: 10)
    exercise.exerciseSets.append(exerciseSet)
    return ExercisesView()
        .modelContainer(modelContainer)
}
