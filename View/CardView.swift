//
//  CardView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2024/12/11.
//

import SwiftUI
import SwiftData

struct CardView: View {
    @State private var text: String = ""
    @Environment(\.modelContext) private var modelContext
    @StateObject private var nfcManager: NFCManager
    
    init() {
        _nfcManager = StateObject(wrappedValue: {
            do {
                let schema = Schema([Item.self])
                let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
                let container = try ModelContainer(for: schema, configurations: [configuration])
                return NFCManager(modelContext: container.mainContext)
            } catch {
                fatalError("無法初始化 ModelContainer: \(error.localizedDescription)")
            }
        }())
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("友だちを探す", text: $text)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 300, height: 50)
                    
                    NavigationLink(destination: MyCardView()) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 40))
                    }
                }
                
                ScrollView(.vertical) {
                    VStack(spacing: 20) {
                        if nfcManager.receivedCards.isEmpty {
                            Text("目前没有交换的名片")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(nfcManager.receivedCards) { card in
                                HStack {
                                    Text(card.name)
                                        .font(.title2)
                                        .padding()
                                        .frame(width: 250, height: 80)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(15)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Button("扫描名片") {
                        nfcManager.startScanning()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("发送我的名片") {
                        nfcManager.writeCardInfo(name: "Oliver's Business Card")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

#Preview {
    CardView()
}
