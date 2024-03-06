//
//  ExerciseSetRow.swift
//  Tracker
//
//  Created by Jesus Lopez on 2/26/24.
//

import SwiftUI

struct ExerciseSetRow: View {
    let exerciseSet: ExerciseSet

    var body: some View {
        let reps = exerciseSet.reps
        let weight = exerciseSet.weight
        HStack {
            PoundsPerSecondView(poundsPerSecond: exerciseSet.poundsPerSecond)
            VStack(alignment: .leading) {
                Text("\(exerciseSet.totalPounds, specifier: "%.f") lbs")
                Text(formatDate(exerciseSet.startedAt))
                    .font(.caption2)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(reps) \(Image(systemName: "arrow.triangle.2.circlepath.circle.fill"))")
                Text("\(weight, specifier: "%.1f") \(Image(systemName: "scalemass.fill"))")
            }
            .font(.caption)
        }
    }

    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Not started" }

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

#Preview {
    let exerciseSet = ExerciseSet()
    return List {
        ExerciseSetRow(exerciseSet: exerciseSet)
        ExerciseSetRow(exerciseSet: exerciseSet)
        ExerciseSetRow(exerciseSet: exerciseSet)
    }
}
