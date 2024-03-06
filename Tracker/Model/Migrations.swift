//
//  Migrations.swift
//  Tracker
//
//  Created by Jesus Lopez on 3/5/24.
//

import Foundation
import SwiftData

enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }

    static let migrateV1toV2 = MigrationStage.custom(fromVersion: SchemaV1.self, toVersion: SchemaV2.self, willMigrate: nil) { context in
        let exerciseSets = try context.fetch(FetchDescriptor<SchemaV2.ExerciseSet>())

        for exerciseSet in exerciseSets {
            var lastDigit = Int(exerciseSet.weight) % 10
            if lastDigit == 2 || lastDigit == 7 {
                exerciseSet.weight += 0.5
            }
        }

        try context.save()
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
}
