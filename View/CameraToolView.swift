//
//  CameraToolView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2024/12/19.
//

import SwiftUI
import AVFoundation

struct CameraToolView: View {
    @Binding var selectedMusic: String?
    @Binding var isPlaying: Bool
    var onPlayPause: () -> Void
    @State private var showSoundView: Bool = false
    
    var body: some View {
        VStack(spacing: 45) {
            //            NavigationLink(destination: SoundView(selectedMusic: $selectedMusic)) {
            Button(action: {
                showSoundView.toggle()
            }) {
                Image(systemName: "music.note")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.white)
            }
            .sheet(isPresented: $showSoundView) { // 這裡使用 sheet
                SoundView(selectedMusic: $selectedMusic) // 顯示 SoundView
            }
            
            //            }
            
            Button {
                onPlayPause()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.white)
            }
        }
                .padding()
    }
}

#Preview {
    CameraToolView(
        selectedMusic: .constant("music1"),
        isPlaying: .constant(false),
        onPlayPause: {}
    )
}
