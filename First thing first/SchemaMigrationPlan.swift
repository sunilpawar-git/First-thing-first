//
//  SchemaMigrationPlan.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftData

struct AppSchemaMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [FirstThingFirstSchema.self]
    }

    public static var migrationStages: [MigrationStage] {
        [
            // Add migration stages here if needed
        ]
    }
}
