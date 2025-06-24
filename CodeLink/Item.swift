//
//  Item.swift
//  CodeLink
//
//  Created by Jamil Turpo on 24/06/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
