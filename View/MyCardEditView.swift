//
//  MyCardEditView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2025/01/30.
//

import SwiftUI
import SwiftData

struct MyCardEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State var name: String = ""
    //    @State var birthYear: String = ""
    @State var gender: String = " オス"
    @State private var editing = false
    @Bindable var card: CardItem
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("名前")
                    .font(.system(size: 18))
                
                TextField("名前を入力してください", text: $card.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("生まれた年（西暦）")
                    .font(.system(size: 18))
                
                TextField("例: 2010", text: $card.birthYear)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("性別")
                    .font(.system(size: 18))
                
                HStack {
                    Button(action: { card.gender = "オス" }) {
                        HStack {
                            Image(systemName: card.gender == "オス" ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(card.gender == "オス" ? .blue : .gray)
                            Text("オス")
                        }
                        .padding()
                    }
                    
                    Button(action: { card.gender = "メス" }) {
                        HStack {
                            Image(systemName: card.gender == "メス" ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(card.gender == "メス" ? .pink : .gray)
                            Text("メス")
                        }
                        .padding()
                    }
                }
                
                Text("Instagram")
                    .font(.system(size: 18))
                
                TextField("Instagramを入力してください", text: Binding(get: {card.instagram ?? ""}, set: { card.instagram = $0 }))
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
            }
            .padding()
            .onAppear {
                /// 進入「編輯」時刪除 `birthYear`
//                card.birthYear = ""
                try? modelContext.save()
            }
            
            Button {
                try? modelContext.save()
                dismiss()
            } label: {
                ZStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 100, height: 50)
                        .cornerRadius(15)
                    
                    Text("保存")
                        .foregroundColor(.white)
                        .bold()
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
}


#Preview {
    MyCardEditView(card: CardItem(name: "トム", birthYear: "2015", gender: "オス", instagram: "tom"))
}
