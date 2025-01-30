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
    @Query private var cards: [CardItem]
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack {
            HStack {
                TextField("友達を探し", text: $messagetext)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                NavigationLink(destination: MyCardEditView()) {
                    Image(systemName: "person.circle")
                        .font(.largeTitle)
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
                    Text("\(card.birthYear) 歳")
                        .font(.caption)
                    Text(card.gender)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    CardView()
}
