//
//  MultipeerManager.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2025/01/30.
//

import Foundation
import MultipeerConnectivity

class MultipeerManager: NSObject, ObservableObject {
    private let serviceType = "chat"
    private let myPeerID = MCPeerID(displayName: "\(UIDevice.current.name)-\(UUID().uuidString.prefix(4))")
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    
    @Published var messages: [String] = []
    @Published var isConnected: Bool = false
    @Published var receivedCards: [CardItem] = []

    override init() {
            super.init()
            
            session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
            session.delegate = self
        print("✅ MCSession 已初始化，Peer ID: \(myPeerID.displayName)")

            
            advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
            advertiser.delegate = self
            advertiser.startAdvertisingPeer()
        print("✅ 廣播已啟動")
            
            browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
            browser.delegate = self
            browser.startBrowsingForPeers()
        print("✅ 搜尋裝置已啟動")
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
    
    func sendCard(_ card: CardItem) {
            do {
                let jsonData = try JSONEncoder().encode(card)
                try session.send(jsonData, toPeers: session.connectedPeers, with: .reliable)
                DispatchQueue.main.async {
                    self.messages.append("📨 已發送名片: \(card.name)")
                }
            } catch {
                print("❌ 傳送名片失敗: \(error.localizedDescription)")
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
            if let receivedCard = try? JSONDecoder().decode(CardItem.self, from: data) {
                DispatchQueue.main.async {
                    self.receivedCards.append(receivedCard)
                    self.messages.append("📩 收到名片: \(receivedCard.name)")
                }
            } else if let message = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.messages.append("\(peerID.displayName): \(message)")
                }
            }
        }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
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
