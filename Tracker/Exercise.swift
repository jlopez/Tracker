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
    var createdAt: Date = Date()
    var name: String

    init(name: String) {
        self.createdAt = Date()
        self.name = name
    }
}
