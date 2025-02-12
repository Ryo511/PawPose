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
        VStack(spacing: 50) {
//            NavigationLink(destination: SoundView(selectedMusic: $selectedMusic)) {
            Button(action: {
                showSoundView.toggle()
            }) {
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(Color.pink)
                    
                    Image(systemName: "music.note")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(Color.white)
                }
            }
            .sheet(isPresented: $showSoundView) { // 這裡使用 sheet
                            SoundView(selectedMusic: $selectedMusic) // 顯示 SoundView
                        }
                
//            }
            
            Button {
                onPlayPause()
            } label: {
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(Color.pink)
                    
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(Color.white)
                }
            }
        }
//        .padding()
    }
}

#Preview {
    CameraToolView(
        selectedMusic: .constant("music1"),
        isPlaying: .constant(false),
        onPlayPause: {}
    )
}
