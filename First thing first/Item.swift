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
    public var title: String
    public var isCompleted: Bool
    public var date: Date
    public var originalDate: Date?
    
    public init(title: String, isCompleted: Bool = false, date: Date = Date(), originalDate: Date? = nil) {
        self.title = title
        self.isCompleted = isCompleted
        self.date = date
        self.originalDate = originalDate
    }
}
