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
            
            VStack {
                List(cards) { card in
                    Text(card.name)
                        .font(.callout)
                    Text("\(card.age) 歳")
                        .font(.caption)
                    Text(card.gender)
                        .font(.caption)
                    
//                        .swipeActions {
//                            Button(role: .destructive) {
//                                deleteCard(card)
//                            } label: {
//                                Label("刪除", systemImage: "trash")
//                            }
//                        }
                }
            }
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
