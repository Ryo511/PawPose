//
//  MultipeerManager.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2025/02/26.
//

import Foundation
import MultipeerConnectivity
import SwiftData

class MultipeerManager: NSObject, ObservableObject {
    private let serviceType = "chat"
    private let myPeerID = MCPeerID(displayName: "\(UIDevice.current.name)-\(UUID().uuidString.prefix(4))")
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    private var modelContext: ModelContext
    
    @Published var messages: [String] = []
    @Published var isConnected: Bool = false
    @Published var receivedCards: [CardItem] = []
    
    private var sentCardIDs: [String] = []
    
    init(modelContext: ModelContext) { // 讓 View 傳入 ModelContext
        self.modelContext = modelContext
        super.init()
        
        if let sentCardIDs = UserDefaults.standard.array(forKey: "sentCardIDs") as? [String] {
            self.sentCardIDs = sentCardIDs
        }
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        print("MCSession 已初始化，Peer ID: \(myPeerID.displayName)")
        
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        print("廣播已啟動")
        
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
        print("搜尋裝置已啟動")
        
        fetchReceivedCards()
    }
    
    private func fetchReceivedCards() {
        let descriptor = FetchDescriptor<CardItem>() // 抓取所有 CardItem
        do {
            let items = try modelContext.fetch(descriptor)
            DispatchQueue.main.async {
                self.receivedCards = items
            }
        } catch {
            print("錯誤抓取已接收名片：\(error)")
        }
    }
    
    func sendMessage(_ text: String) {
        guard !session.connectedPeers.isEmpty, let data = text.data(using: .utf8) else { return }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            DispatchQueue.main.async {
                self.messages.append("你: \(text)")
            }
        } catch {
            print("發送失敗: \(error.localizedDescription)")
        }
    }
    
    func hasSentCard(_ card: CardItem) -> Bool {
        return sentCardIDs.contains(card.id.uuidString)
    }
    
    // 修改為當發送名片後更新已發送的 ID
    func markCardAsSent(_ card: CardItem) {
        var sentCardIDs = UserDefaults.standard.array(forKey: "sentCardIDs") as? [String] ?? []
        if !sentCardIDs.contains(card.id.uuidString) {
            sentCardIDs.append(card.id.uuidString)
            UserDefaults.standard.set(sentCardIDs, forKey: "sentCardIDs")
        }
    }
    
    func sendCard(_ card: CardItem) {
        do {
            let cardToSend = card
            cardToSend.birthYear = card.birthYear.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let storedPhotoData = UserDefaults.standard.data(forKey: "selectedCardPhoto") {
                let base64String = storedPhotoData.base64EncodedString()
                cardToSend.imageData = base64String // 將圖片轉成 Base64 字串
            } else {
                cardToSend.imageData = nil
            }
            
            let jsonData = try JSONEncoder().encode(cardToSend)
            try session.send(jsonData, toPeers: session.connectedPeers, with: .reliable)
            
            DispatchQueue.main.async {
                self.messages.append("已發送名片: \(card.name)")
            }
            
            markCardAsSent(card)
        } catch {
            print("傳送名片失敗: \(error.localizedDescription)")
        }
    }
}

extension MultipeerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.isConnected = true
                self.messages.append("\(peerID.displayName) 已連接")
            case .connecting:
                self.messages.append("\(peerID.displayName) 連線中...")
            case .notConnected:
                self.isConnected = false
                self.messages.append("\(peerID.displayName) 已斷線")
            @unknown default:
                self.messages.append("\(peerID.displayName) 狀態未知")
            }
        }
    }
    
    //    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    //        guard let message = String(data: data, encoding: .utf8) else { return }
    //        DispatchQueue.main.async {
    //            self.messages.append("\(peerID.displayName): \(message)")
    //        }
    //    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let receivedCard = try JSONDecoder().decode(CardItem.self, from: data)
            
            DispatchQueue.main.async {
                let predicate = #Predicate<CardItem> { $0.id == receivedCard.id }
                let descriptor = FetchDescriptor<CardItem>(predicate: predicate)
                
                do {
                    let existingCards = try self.modelContext.fetch(descriptor)
                    if existingCards.isEmpty { // 名片是新的，才插入
                        receivedCard.birthYear = receivedCard.birthYear.trimmingCharacters(in: .whitespacesAndNewlines)
                        self.modelContext.insert(receivedCard)
                        try? self.modelContext.save()
                        self.receivedCards.append(receivedCard) // 更新已發布的陣列
                        self.messages.append("收到名片: \(receivedCard.name)")
                        // ... (處理圖片資料，如同之前一樣)
                    } else {
                        print("這張名片已經存在，跳過儲存")
                        // 如果需要更新現有名片，可以在這裡處理。
                        // 例如：
                        // let existingCard = existingCards.first!
                        // existingCard.name = receivedCard.name // 根據需要更新屬性
                        // try? self.modelContext.save()
                    }
                } catch {
                    print("檢查現有名片時發生錯誤：\(error)")
                }
            }
        } catch {
            print("❌ 無法解析名片: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    func reconnectIfNeeded() {
        if session.connectedPeers.isEmpty {
            print("嘗試重新連線...")
            browser.startBrowsingForPeers()
            advertiser.startAdvertisingPeer()
        }
    }
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}
