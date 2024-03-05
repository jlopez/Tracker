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

    init(exerciseSet: ExerciseSet) {
        self.exerciseSet = exerciseSet
        self._hasStarted = State(wrappedValue: exerciseSet.startedAt != nil)
        self._hasFinished = State(wrappedValue: exerciseSet.endedAt != nil)
    }

    var body: some View {
        Form {
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
                TextField("Weight", value: $exerciseSet.weight, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
            }
        }
        .onChange(of: hasStarted) { old, new in
            if new {
                // TODO: Fix repetition
                exerciseSet.startedAt = .now
            } else {
                exerciseSet.startedAt = nil
            }
        }
        .onChange(of: hasFinished) { old, new in
            if new {
                exerciseSet.endedAt = .now
            } else {
                exerciseSet.endedAt = nil
            }
        }
    }
}

#Preview {
    let exerciseSet = ExerciseSet()
    return EditExerciseSetView(exerciseSet: exerciseSet)
}
