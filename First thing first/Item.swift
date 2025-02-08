//
//  Item.swift
//  First thing first
//
//  Created by Sunil on 08/02/25.
//

import Foundation
import SwiftData

@Model
public class Item {
    public var tasks: [String]
    public var date: Date
    
    public init(tasks: [String] = [], date: Date = Date()) {
        self.tasks = tasks
        self.date = date
    }
}
