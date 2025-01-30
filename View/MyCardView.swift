//
//  MyCardView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2025/01/02.
//

import SwiftUI
import SwiftData

struct MyCardView: View {
    @Environment(\.dismiss) private var dismiss // ✅ 按「完成」時返回 `CardView`
    var name: String
    var birthYear: String
    var gender: String

    var age: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        if let birthYearInt = Int(birthYear) {
            return max(0, currentYear - birthYearInt)
        } else {
            return 0
        }
    }

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Rectangle()
                    .fill(Color.brown.opacity(0.8))
                    .frame(width: 350, height: 550)
                    .cornerRadius(50)

                VStack {
                    Text("名前: \(name)")
                        .font(.title3)
                    Text("年齢: \(age) 歳")
                        .font(.title3)
                    Text("性別: \(gender)")
                        .font(.title3)
                }
                .foregroundColor(.white)
            }
            Spacer()

            Button(action: {
                dismiss() // ✅ 返回 `CardView`
            }) {
                ZStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 100, height: 50)
                        .cornerRadius(15)

                    Text("完成")
                        .foregroundColor(.white)
                        .bold()
                }
            }
            .padding(.bottom, 30)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

#Preview {
    MyCardView(name: "oliver", birthYear: "2010", gender: "オス")
}
