//
//  SchemaMigrationPlan.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftData

struct AppSchemaMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [Item.self]
    }

    static var migrationStages: [MigrationStage] {
        [
            // Add migration stages here if needed
        ]
    }
}
