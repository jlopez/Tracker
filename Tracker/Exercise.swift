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

    init(name: String = "", lastReps: Int = 0, lastWeight: Int = 0) {
        self.name = name
        self.lastReps = lastReps
        self.lastWeight = lastWeight
    }
}

@Model
final class ExerciseSet {
    var startedAt: Date?
    var endedAt: Date?
    var reps: Int
    var weight: Int

    var poundsPerSecond: Double? {
        guard let startedAt = startedAt, let endedAt = endedAt else { return nil }
        return Double(totalPounds) / endedAt.timeIntervalSince(startedAt)
    }

    var totalPounds: Double {
        Double(weight * reps)
    }

    init(startedAt: Date? = nil, endedAt: Date? = nil, reps: Int = 0, weight: Int = 0) {
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.reps = reps
        self.weight = weight
    }
}
