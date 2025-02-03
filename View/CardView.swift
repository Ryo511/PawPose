//
//  CardView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2024/12/11.
//

import SwiftUI
import SwiftData
import MultipeerConnectivity

struct CardView: View {
    @StateObject private var manager: MultipeerManager
    @State private var messagetext: String = ""
    @State private var name: String = ""
    @State var birthYear: String = ""
    @State var gender: String = " オス"
    @AppStorage("myCardID") private var myCardID: String?
    @Query private var cards: [CardItem]
    @Environment(\.modelContext) private var modelContext
    
    init(modelContext: ModelContext) { // ✅ 讓 CardView 初始化時傳入 ModelContext
        _manager = StateObject(wrappedValue: MultipeerManager(modelContext: modelContext))
    }
    var body: some View {
        NavigationStack {
            HStack {
                TextField("友達を探し", text: $messagetext)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                NavigationLink(destination: MyCardView(manager: manager, name: name, birthYear: birthYear, gender: gender)) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 40))
                }
            }
            Spacer()
            
            VStack {
                List(cards) { card in // ✅ 只顯示收到的名片
                    if card.id.uuidString != myCardID { // ✅ 過濾掉自己的名片
                        if let base64String = card.imageData,
                           let imageData = Data(base64Encoded: base64String),
                           let receivedImage = UIImage(data: imageData) {
                            Image(uiImage: receivedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80) // ✅ 設定尺寸
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 5)
                        } else {
                            // ✅ 如果沒有圖片，顯示一個預設圖示
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("名前: \(card.name)")
                                .font(.headline)
                            Text("年齢: \(card.calculateAge()) 歳")
                                .font(.subheadline)
                            Text("性別: \(card.gender)")
                                .font(.subheadline)
                        }
                        .padding()
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteCard(card)
                            } label: {
                                Label("刪除", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .onAppear {
                manager.reconnectIfNeeded()
                
                if let myCard = cards.first {
                    myCardID = myCard.id.uuidString // ✅ 設定自己的名片 ID
                }
            }
            .onReceive(manager.$receivedCards) { newCards in
                manager.reconnectIfNeeded()
                
                for card in newCards {
                    if !cards.contains(where: { $0.id == card.id }) { // ✅ 避免重複存入
                        modelContext.insert(card) // ✅ 存入 SwiftData
                    }
                }
                
                try? modelContext.save() // ✅ 強制存檔
            }
            
            //            Button("清空名片") {
            //                deleteAllCards()
            //            }
            
            
            //            VStack {
            //                List(manager.messages, id: \.self) { message in
            //                    Text(message)
            //                        .font(.caption)
            //                        .foregroundColor(.secondary)
            //                }
            //
            //                Button {
            //                    manager.sendMessage(messagetext)
            //                    messagetext = ""
            //                } label: {
            //                    Text("Send")
            //                }
            //                .disabled(!manager.isConnected)
            //                .padding()
            //            }
            
            //            VStack {
            //                List(cards) { card in
            //                    Text(card.name)
            //                        .font(.callout)
            //                    Text("\(card.age) 歳")
            //                        .font(.caption)
            //                    Text(card.gender)
            //                        .font(.caption)
            
            //                        .swipeActions {
            //                            Button(role: .destructive) {
            //                                deleteCard(card)
            //                            } label: {
            //                                Label("刪除", systemImage: "trash")
            //                            }
            //                        }
            //                }
            //            }
        }
    }
    private func deleteCard(_ card: CardItem) {
        modelContext.delete(card)
        try? modelContext.save()
        
        if let index = manager.receivedCards.firstIndex(where: { $0.id == card.id }) {
            manager.receivedCards.remove(at: index)
        }
    }
    
    //    private func deleteAllCards() {
    //        for card in cards { // ✅ 遍歷所有名片
    //            modelContext.delete(card)
    //        }
    //        try? modelContext.save() // ✅ 儲存變更
    //    }
}

#Preview {
    do {
        let modelContainer = try ModelContainer(for: CardItem.self)
        let modelContext = ModelContext(modelContainer)
        return CardView(modelContext: modelContext)
            .environment(\.modelContext, modelContext)
    } catch {
        return Text("⚠️ 無法初始化 ModelContext: \(error.localizedDescription)")
    }
}
