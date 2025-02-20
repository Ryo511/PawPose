//
//  SoundView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2024/12/16.
//

import SwiftUI
import AVFoundation

struct SoundView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMusic: String?
    @State private var audioPlayer: AVAudioPlayer?
    //    private let musicFiles = (1...23).map { "🎵\($0)" }
    private let musicFiles = ["犬吠える1", "犬吠える2", "犬吠える3", "犬吠える4", "12時", "正しい", "物落ち", "花火1", "花火2", "風鈴", "飛行機", "掃除機", "船", "硬貨", "楽器", "道具", "蝉", "銅", "爆発", "バイク", "ピンポン"]
    
    private let musicFileMapping: [String: String] = [
        "犬吠える1": "犬吠える1",
        "犬吠える2": "犬吠える2",
        "犬吠える3": "犬吠える3",
        "犬吠える4": "犬吠える4",
        "12時": "12時",
        "正しい": "正しい",
        "物落ち": "物落ち",
        "花火1": "花火1",
        "花火2": "花火2",
        "風鈴": "風鈴",
        "飛行機": "飛行機",
        "掃除機": "掃除機",
        "船": "船",
        "硬貨": "硬貨",
        "楽器": "楽器",
        "道具": "道具",
        "蝉": "蝉",
        "銅": "銅",
        "爆発": "爆発",
        "バイク": "バイク",
        "ピンポン": "ピンポン" ]
    
    var body: some View {
        NavigationStack {
            List(musicFiles, id: \.self) { musicName in
                HStack {
                    Text(musicName)
                    Spacer()
                    if selectedMusic == musicName {
                        Image(systemName: "checkmark")
                            .foregroundColor(.orange)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedMusic == musicName {
                        stopMusic()
                        selectedMusic = nil
                    } else {
                        selectedMusic = musicName
                        playMusic(named: musicName)
                    }
                }
            }
            .navigationTitle("全部の音")
        }
        
        //        Button {
        //            dismiss()
        //        } label: {
        //            ZStack {
        //                Rectangle()
        //                    .frame(width: 90, height: 50)
        //                    .foregroundStyle(Color.brown)
        //                    .cornerRadius(25)
        //                Text("選択")
        //                    .foregroundStyle(Color.white)
        //                    .bold()
        //            }
        //        }
        //        .padding()
    }
    
    private func playMusic(named name: String) {
        if audioPlayer?.isPlaying == true {
            stopMusic()
        }
        
        guard let music = musicFileMapping[name],
              let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("找不到音频文件: \(name)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("无法播放音频: \(error.localizedDescription)")
        }
    }
    
    private func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

#Preview {
    SoundView(selectedMusic: .constant(nil))
}
