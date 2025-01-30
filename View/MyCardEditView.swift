//
//  MyCardEditView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2025/01/30.
//

import SwiftUI

struct MyCardEditView: View {
    @State var name: String = ""
    @State var birthYear: String = ""
    @State var gender: String = " オス"
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("名前")
                    .font(.system(size: 18))
                
                TextField("名前を入力してください", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("生まれた年（西暦）")
                    .font(.system(size: 18))
                
                TextField("例: 2010", text: $birthYear)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("性別")
                    .font(.system(size: 18))
                
                HStack {
                    Button(action: { gender = "オス" }) {
                        HStack {
                            Image(systemName: gender == "オス" ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(gender == "オス" ? .blue : .gray)
                            Text("オス")
                        }
                        .padding()
                    }
                    
                    Button(action: { gender = "メス" }) {
                        HStack {
                            Image(systemName: gender == "メス" ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(gender == "メス" ? .pink : .gray)
                            Text("メス")
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .padding()
            
            VStack(alignment: .center, spacing: 30) {
                NavigationLink(destination: MyCardCheckView(name: name, birthYear: birthYear, gender: gender)) {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 80, height: 50)
                            .cornerRadius(15)
                        Text("確認")
                            .foregroundColor(.white)
                            .bold()
                    }
                    .padding()
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
}


#Preview {
    MyCardEditView()
}
