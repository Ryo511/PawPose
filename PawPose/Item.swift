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
    var photoData: Data?
    var latitude: Double?
    var longitude: Double?
    var name: String?

    init(timestamp: Date = Date(), photoData: Data? = nil, latitude: Double? = nil, longitude: Double? = nil, name: String? = nil) {
        self.timestamp = timestamp
        self.photoData = photoData
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
    }
}
