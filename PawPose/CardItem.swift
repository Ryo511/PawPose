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
    var imageData: String?
    
    init(name: String, birthYear: String, gender: String, imageData: String? = nil) {
        self.name = name
        self.birthYear = birthYear.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "2000" : birthYear
        self.gender = gender
        self.imageData = imageData
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
            case id, name, birthYear, gender, imageData
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            self.birthYear = try container.decode(String.self, forKey: .birthYear)
            gender = try container.decode(String.self, forKey: .gender)
            imageData = try? container.decode(String?.self, forKey: .imageData) // 確保 `imageData` 也能存取
            
            if self.birthYear.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        self.birthYear = "2000"
                    }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(birthYear, forKey: .birthYear)
            try container.encode(gender, forKey: .gender)
            
            if let imageData {
                try container.encode(imageData, forKey: .imageData)
            }
        }
    
    func calculateAge(from birthYear: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // 確保格式正確
        formatter.locale = Locale(identifier: "en_US_POSIX") // 避免語系影響
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // 確保時區統一
        
            let currentYear = Calendar.current.component(.year, from: Date())
            guard let birthYearInt = Int(birthYear.trimmingCharacters(in: .whitespacesAndNewlines)),
                  birthYearInt > 1900,
                  birthYearInt <= currentYear else {
                return 0
            }
            return currentYear - birthYearInt
        }
}
