//
//  CardItem.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2025/01/29.
//

import Foundation
import SwiftData

@Model
final class CardItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var birthYear: String
    var gender: String
    var photodata: Data?
    
    init(name: String, birthYear: String, gender: String, photosdata: Data? = nil) {
        self.name = name
        self.birthYear = birthYear
        self.gender = gender
        self.photodata = photodata
    }
    
    var age: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        if let birthYearInt = Int(birthYear) {
            return max(0, currentYear - birthYearInt)
        } else {
            return 0
        }
    }
    
    enum CodingKeys: String, CodingKey {
            case id, name, birthYear, gender
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            birthYear = try container.decode(String.self, forKey: .birthYear)
            gender = try container.decode(String.self, forKey: .gender)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(birthYear, forKey: .birthYear)
            try container.encode(gender, forKey: .gender)
        }
}
