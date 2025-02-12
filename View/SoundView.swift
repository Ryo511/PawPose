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
    private let musicFiles = (1...23).map { "🎵\($0)" }
    
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
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
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
