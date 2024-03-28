//
//  ContentView.swift
//  Tracker
//
//  Created by Jesus Lopez on 1/31/24.
//

import SwiftUI
import SwiftData
import Observation
import AVFoundation

@Observable
class Globals {
    var navigationPath = NavigationPath()
    var lastSet: ExerciseSet?

    @ObservationIgnored var task: Task<(), Never>?

    @ObservationIgnored var synthesizer: AVSpeechSynthesizer!
    @ObservationIgnored var player: AVAudioPlayer?

    init() {
        armSetReminderSound()
    }

    func armSetReminderSound() {
        withObservationTracking {
            guard let lastSet = lastSet,
                  let endedAt = lastSet.endedAt else { return }
            let expiration = endedAt.addingTimeInterval(120-10-2).timeIntervalSinceNow
            guard expiration > 0 else { return }
            task = Task {
                try? await Task.sleep(nanoseconds: UInt64(expiration * 1_000_000_000))
                if task?.isCancelled ?? true { return }
                self.playSetReminderSound()
            }
        } onChange: {
            self.task?.cancel()
            self.task = nil
            Task { self.armSetReminderSound() }
        }
    }

    func playSetReminderSound() {
        let utterance = AVSpeechUtterance(string: "Ten seconds!")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)

        guard let url = Bundle.main.url(forResource: "bell", withExtension: "m4a") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}

var globals = Globals()

enum Screens : Hashable {
    case stats(Exercise)

    @ViewBuilder
    func createView() -> some View {
        switch self {
        case .stats(let exercise): ExerciseStatsView(exercise: exercise)
        }
    }
}

struct ExercisesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    @State private var showAddExercise: Bool = false
    @State private var globals = Tracker.globals

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
            .navigationDestination(for: Screens.self) { $0.createView() }
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
