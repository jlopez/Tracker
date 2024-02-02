//
//  Item.swift
//  Tracker
//
//  Created by Jesus Lopez on 1/31/24.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    var createdAt = Date()
    var name: String
    @Relationship(deleteRule: .cascade)
    var exerciseSets: [ExerciseSet]! = []
    var lastReps: Int
    var lastWeight: Int

    init(name: String, lastReps: Int = 0, lastWeight: Int = 0) {
        self.name = name
        self.lastReps = lastReps
        self.lastWeight = lastWeight
    }
}

@Model
final class ExerciseSet {
    var startedAt: Date
    var endedAt: Date
    var reps: Int
    var weight: Int

    var poundsPerSecond: Double {
        Double(totalPounds) / endedAt.timeIntervalSince(startedAt)
    }

    var totalPounds: Double {
        Double(weight * reps)
    }

    init(startedAt: Date, endedAt: Date, reps: Int, weight: Int) {
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.reps = reps
        self.weight = weight
    }
}
