//
//  Item.swift
//  ClimaAgora
//
//  Created by Fernando on 17/03/26.
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
