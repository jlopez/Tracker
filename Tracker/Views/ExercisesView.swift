//
//  ContentView.swift
//  Tracker
//
//  Created by Jesus Lopez on 1/31/24.
//

import SwiftUI
import SwiftData
import Observation
import UserNotifications

@Observable
class Globals: NSObject, UNUserNotificationCenterDelegate {
    var navigationPath = NavigationPath()
    var lastSet: ExerciseSet?

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        armReminderNotification()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return .sound
    }

    func armReminderNotification() {
        withObservationTracking {
            guard let lastSet = lastSet,
                  let endedAt = lastSet.endedAt else { return }
            let expiration = endedAt.addingTimeInterval(10-2).timeIntervalSinceNow
            guard expiration > 0 else { return }

            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                guard success else { return }
                let content = UNMutableNotificationContent()
                content.title = "Tracker"
                content.body = "Ten seconds!"
                content.sound = .init(named: .init("bell.m4a"))
                content.interruptionLevel = .active
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: expiration, repeats: false)
                let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        } onChange: {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["reminder"])
            Task { self.armReminderNotification() }
        }
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
