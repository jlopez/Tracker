//
//  Model-v2.swift
//  Tracker
//
//  Created by Jesus Lopez on 3/5/24.
//

import Foundation
import SwiftData

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Exercise.self, ExerciseSet.self]
    }

    @Model
    final class Exercise {
        var createdAt = Date()
        var name: String = ""
        @Relationship(deleteRule: .cascade)
        var exerciseSets: [ExerciseSet]! = []

        init(createdAt: Date = .now, name: String = "", exerciseSets: [ExerciseSet] = []) {
            self.createdAt = createdAt
            self.name = name
            self.exerciseSets = exerciseSets
        }

        // MARK: - ExerciseSet management

        /// Return all sets with the same waking day as the provided date
        /// - parameter date: The date for which to return the sets
        /// - returns: The sets sorted by time
        func sets(for date: Date) -> [ExerciseSet] {
            let wakingDay = Calendar.current.startOfWakingDay(for: date)
            return exerciseSets
                .filter { $0.wakingDay == wakingDay }
                .sorted { $0.endedAt ?? .distantPast < $1.endedAt ?? .distantPast }
        }

        /// Return the previous sets from the provided date
        /// - parameter date: The date for which to return the previous sets
        /// - returns: The sets sorted by time
        func previousSets(from date: Date) -> [ExerciseSet] {
            guard let previousDay = dayWithSets(before: date) else { return [] }
            return sets(for: previousDay)
        }

        /// Return the day with sets before the provided date
        /// - parameter date: The reference date
        /// - returns: The day with sets before the provided date
        func dayWithSets(before date: Date) -> Date? {
            let previousDay = Calendar.current.date(wakingDaysAgo: 1, from: date)
            return exerciseSets
                .compactMap { $0.endedAt }
                .map { Calendar.current.startOfWakingDay(for: $0) }
                .filter { $0 <= previousDay }
                .max()
        }
    }

    @Model
    final class ExerciseSet {
        var exercise: Exercise?
        var startedAt: Date?
        var endedAt: Date?
        var reps: Int = 0
        var weight: Double = 0

        var poundsPerSecond: Double? {
            guard let startedAt = startedAt, let endedAt = endedAt else { return nil }
            return Double(totalPounds) / endedAt.timeIntervalSince(startedAt)
        }

        var totalPounds: Double {
            weight * Double(reps)
        }

        /// The waking day for the set or today if the set hasn't started yet
        /// - returns: The start of the waking day for the set (e.g. Monday 4am)
        var wakingDay: Date {
            Calendar.current.startOfWakingDay(for: startedAt ?? Date())
        }

        init(exercise: Exercise? = nil, startedAt: Date? = nil, endedAt: Date? = nil, reps: Int = 0, weight: Double = 0) {
            self.exercise = exercise
            self.startedAt = startedAt
            self.endedAt = endedAt
            self.reps = reps
            self.weight = weight
        }
    }
}

