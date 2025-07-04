//
//  FirstThingFirstSchema.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import SwiftData

enum FirstThingFirstSchema: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Item.self]
    }

    static var versionIdentifier: Schema.Version {
        .init(1, 0, 0)
    }
}
