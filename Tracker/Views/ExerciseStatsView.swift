//
//  ExerciseStatsView.swift
//  Tracker
//
//  Created by Jesus Lopez on 3/5/24.
//

import SwiftUI

struct SetWithInfo {
    let exerciseSet: ExerciseSet
    let day: Date
    var rank: Int
}

extension ExerciseSet {
    var day: Date? {
        guard let endedAt = endedAt else { return nil }
        return Calendar.current.startOfDay(for: endedAt)
    }
}

struct ExerciseStatsView: View {
    let exercise: Exercise
    let groupedByDay: [Date: [SetWithInfo]]
    let days: [Date]

    init(exercise: Exercise) {
        self.exercise = exercise
        let setsWithDate = exercise.exerciseSets.filter { $0.poundsPerSecond != nil }
        let rankedSets = setsWithDate
            .sorted { $0.poundsPerSecond ?? 0 > $1.poundsPerSecond ?? 0 }
            .enumerated()
            .map { SetWithInfo(exerciseSet: $0.element, day: $0.element.day!, rank: $0.offset + 1) }
        groupedByDay = Dictionary(grouping: rankedSets) { $0.day }
        days = groupedByDay.keys.sorted { $0 > $1 }
    }

    var body: some View {
        List {
            ForEach(days, id: \.self) { day in
                Section(header: Text(day, style: .date)) {
                    let sets = groupedByDay[day]!.sorted { $0.exerciseSet.poundsPerSecond! > $1.exerciseSet.poundsPerSecond! }
                    DayStatRow(sets: sets)
                    ForEach(sets, id: \.rank) { info in
                        ExerciseSetStatRow(info: info)
                    }
                }
            }
        }
    }
}

struct ExerciseSetStatRow : View {
    let info: SetWithInfo

    var body: some View {
        HStack {
            PoundsPerSecondView(poundsPerSecond: info.exerciseSet.poundsPerSecond)
            Text("#\(info.rank) - ")
                .font(.title2)
            Text(info.exerciseSet.endedAt!, style: .time)
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(info.exerciseSet.reps) \(Image(systemName: "arrow.triangle.2.circlepath.circle.fill"))")
                Text("\(info.exerciseSet.weight, specifier: "%.1f") \(Image(systemName: "scalemass.fill"))")
            }
            .font(.caption)
        }
    }
}

struct DayStatRow : View {
    let sets: [SetWithInfo]

    var body: some View {
        let totalPounds = sets.reduce(0) { $0 + $1.exerciseSet.totalPounds }
        let totalReps = sets.reduce(0) { $0 + $1.exerciseSet.reps }
        let averagePoundsPerSecond = sets.reduce(0) { $0 + ($1.exerciseSet.poundsPerSecond ?? 0) } / Double(sets.count)
        let minTime = sets.min { $0.exerciseSet.endedAt! < $1.exerciseSet.endedAt! }!.exerciseSet.endedAt!
        let maxTime = sets.max { $0.exerciseSet.endedAt! < $1.exerciseSet.endedAt! }!.exerciseSet.endedAt!
        let duration = maxTime.timeIntervalSince(minTime)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        HStack {
            PoundsPerSecondView(poundsPerSecond: averagePoundsPerSecond)
            VStack(alignment: .leading) {
                Text("Total \(hours):\(minutes, specifier: "%02d"):\(seconds, specifier: "%02d")")
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(totalReps) \(Image(systemName: "arrow.triangle.2.circlepath.circle.fill"))")
                Text("\(totalPounds, specifier: "%.f") \(Image(systemName: "scalemass.fill"))")
            }
            .font(.caption)
        }
    }
}

#Preview {
    let exercise = Exercise(name: "Biceps Curl")
    return ExerciseStatsView(exercise: exercise)
}
