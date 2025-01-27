//
//  NFCManager.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2025/01/24.
//

import Foundation
import CoreNFC
import SwiftData

class NFCManager: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var receivedCards: [BusinessCard] = []
    private var session: NFCNDEFReaderSession?
    var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        super.init()
        startScanning() // 應用啟動時自動掃描
    }

    func startScanning() {
        
        DispatchQueue.main.async {
               if NFCNDEFReaderSession.readingAvailable {
                   self.session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
                   self.session?.alertMessage = "请将您的 iPhone 靠近对方设备以交换名片"
                   self.session?.begin()
               } else {
                   print("❌ NFC 不支持 - 可能的原因：硬體問題、設定限制或權限缺失")
               }
           }
        
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC 不支持")
            return
        }

        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "请将您的 iPhone 靠近对方设备以交换名片"
        session?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            for message in messages {
                for record in message.records {
                    if record.payload.count > 3 {
                        let data = record.payload.subdata(in: 3..<record.payload.count)
                        if let cardInfo = String(data: data, encoding: .utf8) {
                            let newCard = BusinessCard(id: UUID(), name: cardInfo)
                            self.receivedCards.append(newCard)
                            self.saveCardLocally(card: newCard)
                        }
                    }
                }
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            print("NFC 读取失败: \(error.localizedDescription)")
        }
    }

    private func saveCardLocally(card: BusinessCard) {
        let newCard = Item(timestamp: Date(), name: card.name)
        modelContext.insert(newCard)
        do {
            try modelContext.save()
            print("名片保存成功")
        } catch {
            print("保存名片失败: \(error.localizedDescription)")
        }
    }
    
    func writeCardInfo(name: String) {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC 不支持")
            return
        }
        
        let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: name, locale: .current)!
        _ = NFCNDEFMessage(records: [payload])
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "将手机靠近其他设备以写入名片信息"
        session?.begin()
    }
}

struct BusinessCard: Identifiable, Hashable {
    var id: UUID
    var name: String
}
