//
//  ExerciseSetsView.swift
//  Tracker
//
//  Created by Jesus Lopez on 1/31/24.
//

import SwiftUI

struct ExerciseSetsView: View {
    @Environment(\.modelContext) var modelContext
    let exercise: Exercise
    @State var showAddSet: Bool = false

    var body: some View {
        List {
            ForEach(exercise.exerciseSets) { exerciseSet in
                ExerciseSetRow(exerciseSet: exerciseSet)
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

struct ExerciseSetRow: View {
    let exerciseSet: ExerciseSet

    var body: some View {
        let reps = exerciseSet.reps
        let weight = exerciseSet.weight
        HStack {
            PoundsPerSecondView(poundsPerSecond: exerciseSet.poundsPerSecond)
            VStack(alignment: .leading) {
                Text("\(reps * weight) lbs")
                Text(formatDate(exerciseSet.startedAt))
                    .font(.caption2)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(reps) \(Image(systemName: "arrow.triangle.2.circlepath.circle.fill"))")
                Text("\(weight) \(Image(systemName: "scalemass.fill"))")
            }
            .font(.caption)
        }
    }

    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date.now
        let startOfToday = calendar.startOfDay(for: now)
        let startOfDayOnDate = calendar.startOfDay(for: date)
        let formatter = DateFormatter()

        let daysFromToday = calendar.dateComponents([.day], from: startOfToday, to: startOfDayOnDate).day!

        if abs(daysFromToday) <= 1 {
            // Yesterday, today or tomorrow
            formatter.dateStyle = .full
            formatter.timeStyle = .short
            formatter.doesRelativeDateFormatting = true
        }
        else if calendar.component(.year, from: date) == calendar.component(.year, from: now) {
            // Another date this year
            formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
        }
        else {
            // Another date in another year
            formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMMyyyy")
        }
        return formatter.string(from: date)
    }
}

struct PoundsPerSecondView: View {
    let poundsPerSecond: Double

    var body: some View {
        let decimals = poundsPerSecond < 10 ? 1 : 0
        let hue = min(max(0, poundsPerSecond / 100), 1) / 3
        Text(poundsPerSecond, format: .number.precision(.fractionLength(decimals)))
            .foregroundColor(Color(hue: hue, saturation: 1, brightness: 1))
            .fontWeight(.bold)
            .font(.title3)
    }
}

struct NewExerciseSetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    var exercise: Exercise
    @State private var startedAt = Date()
    @State private var autoEnd = true
    @State private var endedAt = Date()
    @State private var reps: Int
    @State private var weight: Int

    let numberFormatter: NumberFormatter = {
          let formatter = NumberFormatter()
          formatter.zeroSymbol = ""
          return formatter
     }()

    init(exercise: Exercise) {
        self.exercise = exercise
        self._reps = State(initialValue: exercise.lastReps)
        self._weight = State(initialValue: exercise.lastWeight)
    }

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
        exercise.lastReps = reps
        exercise.lastWeight = weight
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
