//
//  MyCardCheckView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2025/01/30.
//

import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

struct MyCardCheckView: View {
    @Environment(\.modelContext) private var modelContext // save to swiftdata
    @Environment(\.dismiss) private var dismiss // 返回上一個畫面
    @State var name: String
    @State var birthYear: String
    @State var gender: String
    @State private var saved = false // ✅ 控制是否跳轉到 `MyCardView`
    @State private var editing = false // ✅ 控制是否跳轉到 `MyCardEditView`

    var age: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        if let birthYearInt = Int(birthYear) {
            return max(0, currentYear - birthYearInt)
        } else {
            return 0
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 15) {
                Text("名前").font(.system(size: 20))
                Text(name).font(.system(size: 20))

                Text("年齢").font(.system(size: 20))
                Text("\(age)歳").font(.system(size: 20))

                Text("性別").font(.system(size: 20))
                Text(gender).font(.system(size: 20))

                Spacer()

                // ✅ 透過 `isActive` 控制跳轉到 `MyCardEditView`
                NavigationLink(destination: MyCardEditView(name: name, birthYear: birthYear, gender: gender), isActive: $editing) {
                    Button {
                        editing = true
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(Color.pink)
                                .frame(width: 80, height: 50)
                                .cornerRadius(15)
                            Text("編集")
                                .foregroundColor(.white)
                                .bold()
                        }
                        .padding()
                    }
                }

                // ✅ 透過 `isActive` 控制跳轉到 `MyCardView`
                NavigationLink(destination: MyCardView(name: name, birthYear: birthYear, gender: gender), isActive: $saved) {
                    Button(action: saveCard) {
                        ZStack {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 80, height: 50)
                                .cornerRadius(15)
                            Text("保存")
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                }
            }
        }
    }

    // ✅ 先儲存名片，再觸發跳轉到 `MyCardView`
    private func saveCard() {
        let newCard = CardItem(name: name, birthYear: birthYear, gender: gender)
        modelContext.insert(newCard)
        print("✅ 名片已儲存: \(newCard.name), \(newCard.birthYear), \(newCard.gender)")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            saved = true
        }
    }
}

#Preview {
    MyCardCheckView(name: "oliver", birthYear: "2010", gender: "オス")
}
