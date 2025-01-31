//
//  MyCardView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2025/01/02.
//

import SwiftUI
import SwiftData

struct MyCardView: View {
    @StateObject private var manager = MultipeerManager()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var item: [Item]
    @Query private var cards: [CardItem]
    @State private var selectedPhoto: UIImage? // ✅ 存儲選擇的照片
    @State private var isPhotoPickerPresented = false // ✅ 控制是否顯示照片選擇器
    @AppStorage("selectedCardPhoto") private var storedPhotoData: Data?
    
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
        NavigationStack {
            VStack {
                Spacer()
                if let card = cards.first {
                ZStack {
                    Rectangle()
                        .fill(Color.brown.opacity(0.8))
                        .frame(width: 350, height: 550)
                        .cornerRadius(50)
                    
                    VStack {
                        VStack {
                            if let selectedPhoto = selectedPhoto {
                                Image(uiImage: selectedPhoto)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 10)
                                //                                    .onTapGesture {
                                //                                        isPhotoPickerPresented = true
                                //                                    }
                                //                                    .padding()
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.9))
                                        .frame(width: 150, height: 150)
                                    
                                    Image(systemName: "photo.on.rectangle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.black)
                                }
                                //                                .onTapGesture {
                                //                                    isPhotoPickerPresented = true // ✅ 點擊後選擇照片
                                //                                }
                            }
                        }
                        .padding(.bottom, 40)
                        
                        
                            Text("名前: \(card.name)")
                                .font(.system(size: 25))
                                .padding(5)
                            Text("年齢: \(card.age) 歳")
                                .font(.system(size: 25))
                                .padding(5)
                            Text("性別: \(card.gender)")
                                .font(.system(size: 25))
                                .padding(5)
                        }
                            .foregroundColor(.white)
                    }
                    .onTapGesture {
                        manager.sendCard(card) // ✅ 點擊發送名片
                    }
                }
                
                Spacer()
                if let card = cards.first {
                    NavigationLink(destination: MyCardEditView(card: card)) {
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
                } else {
                    Button("新規作成") {
                        let newCard = CardItem(name: "トム", birthYear: "2014", gender: "オス")
                        modelContext.insert(newCard) // ✅ 新增名片
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPhotoPickerPresented = true // ✅ 點擊 + 號後開啟照片選擇器
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title)
                    }
                }
            }
            .sheet(isPresented: $isPhotoPickerPresented) {
                PhotoPickerView(selectedPhoto: $selectedPhoto, items: item, storedPhotoData: $storedPhotoData)
            }
            .onAppear {
                loadStoredPhoto() // ✅ 載入已儲存的照片
            }
        }
    }
    private func loadStoredPhoto() {
        if let storedPhotoData, let uiImage = UIImage(data: storedPhotoData) {
            selectedPhoto = uiImage
        }
    }
}

#Preview {
    MyCardView(name: "トム", birthYear: "2014", gender: "オス")
}
