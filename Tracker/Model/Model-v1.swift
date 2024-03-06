//
//  Model-v1.swift
//  Tracker
//
//  Created by Jesus Lopez on 3/5/24.
//

import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

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
    }

    @Model
    final class ExerciseSet {
        var exercise: Exercise?
        var startedAt: Date?
        var endedAt: Date?
        var reps: Int = 0
        var weight: Int = 0

        var poundsPerSecond: Double? {
            guard let startedAt = startedAt, let endedAt = endedAt else { return nil }
            return Double(totalPounds) / endedAt.timeIntervalSince(startedAt)
        }

        var totalPounds: Double {
            Double(weight * reps)
        }

        init(exercise: Exercise? = nil, startedAt: Date? = nil, endedAt: Date? = nil, reps: Int = 0, weight: Int = 0) {
            self.exercise = exercise
            self.startedAt = startedAt
            self.endedAt = endedAt
            self.reps = reps
            self.weight = weight
        }
    }
}

