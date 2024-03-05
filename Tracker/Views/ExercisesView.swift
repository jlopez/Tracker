//
//  ContentView.swift
//  Tracker
//
//  Created by Jesus Lopez on 1/31/24.
//

import SwiftUI
import SwiftData

@Observable
class Globals {
    var navigationPath = NavigationPath()
}

struct ExercisesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    @State private var showAddExercise: Bool = false
    @State private var globals = Globals()

    var body: some View {
        NavigationStack(path: $globals.navigationPath) {
            List {
                ForEach(exercises) { exercise in
                    NavigationLink(value: exercise) {
                        Text(exercise.name)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button("Add Exercise", systemImage: "plus", action: addExercise)
                }
            }
            .navigationTitle("Exercises")
            .navigationDestination(for: Exercise.self) { EditExerciseView(exercise: $0) }
            .navigationDestination(for: ExerciseSet.self) { EditExerciseSetView(exerciseSet: $0) }
        }
        .environment(globals)
    }

    private func addExercise() {
        let exercise = Exercise()
        modelContext.insert(exercise)
        globals.navigationPath.append(exercise)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(exercises[index])
            }
        }
    }
}

#Preview {
    let modelContainer = try! ModelContainer(for: Exercise.self, configurations: .init(isStoredInMemoryOnly: true))
    let exercise = Exercise(name: "Biceps Curl")
    modelContainer.mainContext.insert(exercise)
    let endedAt = Date()
    let startedAt = endedAt.addingTimeInterval(-17.38)
    let exerciseSet = ExerciseSet(startedAt: startedAt, endedAt: endedAt, reps: 8, weight: 10)
    exercise.exerciseSets.append(exerciseSet)
    return ExercisesView()
        .modelContainer(modelContainer)
}
