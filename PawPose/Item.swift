//
//  Item.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2024/12/11.
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
