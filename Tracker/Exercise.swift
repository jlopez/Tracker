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

    init(name: String) {
        self.name = name
    }
}

@Model
final class ExerciseSet {
    var startedAt: Date
    var endedAt: Date
    var reps: Int
    var weight: Int

    init(startedAt: Date, endedAt: Date, reps: Int, weight: Int) {
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.reps = reps
        self.weight = weight
    }
}
