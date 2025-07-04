//
//  SchemaMigrationPlan.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftData

enum SchemaMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [First_thing_firstSchema.self]
    }

    static var migrationStages: [MigrationStage] {
        [
            // Add migration stages here if needed
        ]
    }
}
