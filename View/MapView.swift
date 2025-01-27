//
//  MapView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2024/12/11.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var coordinateRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6982316, longitude: 139.6981199),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedItem: Item?
    @State private var isSheetPresented = false
    var body: some View {
        NavigationStack {
            ZStack {
                Map(initialPosition: .region(coordinateRegion)) {
                    ForEach(items) { item in
                        if let lat = item.latitude, let lon = item.longitude,
                           let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                            
                            let adjustedLatitude = lat + randomOffset()
                            let adjustedLongitude = lon + randomOffset()
                            
                            Annotation("Photo", coordinate: CLLocationCoordinate2D(latitude: adjustedLatitude, longitude: adjustedLongitude)) {
                                NavigationLink {
                                    PhotoDetailView(item: item, deleteAction: deleteItem)
                                } label: {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                }
                                
//                                Button {
//                                    selectedItem = item
//                                    isSheetPresented.toggle()
//                                } label: {
//                                    Image(uiImage: uiImage)
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 50, height: 50)
//                                        .clipShape(Circle())
//                                        .shadow(radius: 3)
//                                }
                            }
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                        .mapControlVisibility(.visible)
                }
            }
            //            .ignoresSafeArea()
            .toolbar(.hidden, for: .navigationBar)
            //            .sheet(isPresented: $isSheetPresented) {
            //                if let selectedItem = selectedItem {
            //                    PhotoDetailView(item: selectedItem, deleteAction: deleteItem)
            //                }
            //            }
        }
    }
    
    private func randomOffset() -> Double {
        return Double.random(in: -0.0005...0.0005) // 讓照片呈現是分開的
    }
    
    private func deleteItem(_ item: Item) {
        DispatchQueue.main.async {
            withAnimation {
                modelContext.delete(item)
                try? modelContext.save()
            }
        }
    }
}

#Preview {
    MapView()
}
