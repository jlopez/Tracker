//
//  EditExerciseSetView.swift
//  Tracker
//
//  Created by Jesus Lopez on 2/23/24.
//

import SwiftUI

struct EditExerciseSetView: View {
    @Bindable var exerciseSet: ExerciseSet
    @State private var hasStarted = false
    @State private var hasFinished = false
    @Environment(Globals.self) private var globals: Globals?

    var doubleFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }

    init(exerciseSet: ExerciseSet) {
        self.exerciseSet = exerciseSet
        self._hasStarted = State(wrappedValue: exerciseSet.startedAt != nil)
        self._hasFinished = State(wrappedValue: exerciseSet.endedAt != nil)
    }

    var body: some View {
        Form {
            if let lastSet = globals?.lastSet,
               lastSet != exerciseSet,
               let lastSetEndedAt = lastSet.endedAt {
                Section("Last Set") {
                    Text("Completed \(lastSetEndedAt, style: .relative) ago")
                }
            }
            Section {
                if let endedAt = exerciseSet.endedAt {
                    HStack {
                        PoundsPerSecondView(poundsPerSecond: exerciseSet.poundsPerSecond)
                        Text("Completed \(endedAt, style: .relative) ago")
                    }
                } else if let startedAt = exerciseSet.startedAt {
                    Text("Started \(startedAt, style: .relative) ago")
                } else {
                    Text("Not started")
                }
            }

            Section {
                Toggle("Started", isOn: $hasStarted)
                if hasStarted {
                    // TODO: Fix repetition
                    DatePicker("startedAt", selection: $exerciseSet.startedAt ?? Date())
                }
                Toggle("Completed", isOn: $hasFinished)
                if hasFinished {
                    DatePicker("endedAt", selection: $exerciseSet.endedAt ?? Date())
                }
                TextField("Reps", value: $exerciseSet.reps, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                Stepper {
                    TextField("Weight", value: $exerciseSet.weight, formatter: doubleFormatter)
                        .keyboardType(.decimalPad)
                } onIncrement: {
                    increaseWeight()
                } onDecrement: {
                    decreaseWeight()
                }
            }
        }
        .onChange(of: hasStarted) { old, new in
            if new {
                // TODO: Fix repetition
                exerciseSet.startedAt = .now
                globals?.lastSet = exerciseSet
            } else {
                exerciseSet.startedAt = nil
            }
        }
        .onChange(of: hasFinished) { old, new in
            if new {
                exerciseSet.endedAt = .now
                globals?.lastSet = exerciseSet
            } else {
                exerciseSet.endedAt = nil
            }
        }
    }

    func increaseWeight() {
        let weight = exerciseSet.weight
        if weight < 25 {
            exerciseSet.weight = (floor(weight / 2.5) + 1) * 2.5
        } else if weight < 50 {
            exerciseSet.weight = (floor(weight / 5) + 1) * 5
        } else if weight < 52.5 {
            exerciseSet.weight = 52.5
        }
    }

    func decreaseWeight() {
        let weight = exerciseSet.weight
        if weight > 52.5 {
            exerciseSet.weight = 52.5
        } else if weight > 25 {
            exerciseSet.weight = (ceil(weight / 5) - 1) * 5
        } else if weight > 5 {
            exerciseSet.weight = (ceil(weight / 2.5) - 1) * 2.5
        }
    }
}

#Preview {
    let exerciseSet = ExerciseSet()
    return EditExerciseSetView(exerciseSet: exerciseSet)
}
