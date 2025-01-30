//
//  CardItem.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2025/01/29.
//

import Foundation
import SwiftData

@Model
final class CardItem: Identifiable {
    var id = UUID()
    var name: String
    var birthYear: String
    var gender: String
    
    init(name: String, birthYear: String, gender: String) {
        self.name = name
        self.birthYear = birthYear
        self.gender = gender
    }
    
    var age: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        if let birthYearInt = Int(birthYear) {
            return max(0, currentYear - birthYearInt)
        } else {
            return 0
        }
    }
}
