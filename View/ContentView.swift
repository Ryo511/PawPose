//
//  ContentView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2024/12/11.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "dog")
                    }
                    .tag(0)
                
                MapView()
                    .tabItem {
                        Label("Map", systemImage: "pin")
                    }
                    .tag(1)
                
                CameraView()
                    .tabItem {
                        Label("Camera", systemImage: "camera")
                    }
                    .tag(2)
                
                CardView(modelContext: modelContext)
                    .tabItem {
                        Label("Find", systemImage: "heart")
                    }
                    .tag(3)
            }
        }
    }
}

#Preview {
    ContentView()
}
