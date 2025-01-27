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
    
    var body: some View {
        HStack(spacing: 50) {
            NavigationLink(destination: SoundView(selectedMusic: $selectedMusic)) {
                ZStack {
                    Circle()
                        .frame(width: 65, height: 65)
                        .foregroundStyle(Color.brown)
                    
                    Image(systemName: "music.note")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(Color.white)
                }
            }
            
            Button {
                onPlayPause()
            } label: {
                ZStack {
                    Circle()
                        .frame(width: 65, height: 65)
                        .foregroundStyle(Color.brown)
                    
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
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
