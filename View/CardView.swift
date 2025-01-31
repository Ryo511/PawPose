//
//  CardView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2024/12/11.
//

import SwiftUI
import SwiftData

struct CardView: View {
    @StateObject private var manager = MultipeerManager()
    @State private var messagetext: String = ""
    @State private var name: String = ""
    @State var birthYear: String = ""
    @State var gender: String = " オス"
    @AppStorage("myCardID") private var myCardID: String?
    @Query private var cards: [CardItem]
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        NavigationStack {
            HStack {
                TextField("友達を探し", text: $messagetext)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                NavigationLink(destination: MyCardView(name: name, birthYear: birthYear, gender: gender)) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 40))
                }
            }
            Spacer()
            
            VStack {
                            List(manager.receivedCards) { card in // ✅ 只顯示收到的名片
                                if card.id.uuidString != myCardID { // ✅ 過濾掉自己的名片
                                    VStack(alignment: .leading) {
                                        Text("名前: \(card.name)")
                                            .font(.headline)
                                        Text("年齢: \(card.age) 歳")
                                            .font(.subheadline)
                                        Text("性別: \(card.gender)")
                                            .font(.subheadline)
                                    }
                                    .padding()
                                }
                            }
                        }
                        .onAppear {
                            if let myCard = cards.first {
                                myCardID = myCard.id.uuidString // ✅ 設定自己的名片 ID
                            }
                        }
                        .onReceive(manager.$receivedCards) { newCards in
                            for card in newCards {
                                if card.id.uuidString != myCardID { // ✅ 過濾自己的名片
                                    modelContext.insert(card) // ✅ 存入 SwiftData
                                }
                            }
                        }
            
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
    }
}

#Preview {
    CardView()
}
