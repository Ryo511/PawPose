//
//  CameraView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2024/12/12.
//

import SwiftUI
import PhotosUI
import AVFoundation
import SwiftData

struct CameraView: View {
    @Environment(\.modelContext) var modelContext
    @State private var capturedImage: UIImage?
    @State private var isImageProcessed = false
    @State private var isPresented: Bool = false
    @State private var isPreviewingPhoto: Bool = false
    @State private var selectedMusic: String? = nil
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying: Bool = false
    @State private var volume: Double = 50.0
    @State private var isPhotoPickerPresented: Bool = false
    @State private var selectedPhotos: [IdentifiableImage] = []
    @State private var editingPhoto: IdentifiableImage? = nil
    @ObservedObject var locationManager = LocationManager()
    @State private var musiclist: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                Button {
                    isPresented = true
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 190, height: 150)
                            .cornerRadius(20)
                        Image(systemName: "camera.fill")
                            .resizable()
                            .frame(width: 80, height: 70)
                            .foregroundStyle(Color.white)
                    }
                }
                
                Button {
                    isPhotoPickerPresented = true
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 190, height: 150)
                            .cornerRadius(20)
                        Image(systemName: "photo.fill")
                            .resizable()
                            .frame(width: 80, height: 70)
                            .foregroundStyle(Color.white)
                    }
                }
                
                if selectedPhotos.isEmpty {
                    Text("写真を選択")
                } else {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedPhotos) { photo in
                                Image(uiImage: photo.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .cornerRadius(10)
                                    .clipped()
                                    .onTapGesture {
                                        editingPhoto = photo
                                        isPreviewingPhoto = true
                                    }
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding(.bottom, 50)
//            .overlay(
//                CameraToolView(
//                    selectedMusic: $selectedMusic,
//                    isPlaying: $isPlaying,
//                    onPlayPause: toggleMusicPlayback
//                )
//                .padding(.top, 570)
//            )
//            .fullScreenCover(isPresented: $isPresented) {
//                VStack {
//                    ImagePickerView(capturedImage: $capturedImage, isPresented: $isPresented) {
//                        handleCapturedImage()
//                    }
//                    .edgesIgnoringSafeArea(.all)
            .fullScreenCover(isPresented: $isPresented) {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    ImagePickerView(capturedImage: $capturedImage, isPresented: $isPresented) {
                        handleCapturedImage()
                    }
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        HStack {
                            CameraToolView(
                                selectedMusic: $selectedMusic,
                                isPlaying: $isPlaying,
                                onPlayPause: toggleMusicPlayback
                            )
                            .padding(.leading, 5)
                            Spacer()
                        }
                        Spacer()
                    }
                    
//                        Button(action: {
//                            musiclist = true
//                        }) {
//                            Image(systemName: "music")
//                                .font(.title3)
//                        }
//                        .sheet(isPresented: $musiclist) {
//                            SoundView(selectedMusic: $selectedMusic)
//                        }
                    }
                .onDisappear {
                    stopMusic()
                }
            }
            .onChange(of: capturedImage) { _, _ in
                if let capturedImage, !isImageProcessed {
                    handleCapturedImage()
                }
            }
            .navigationDestination(isPresented: $isPreviewingPhoto) {
                if let photo = editingPhoto {
                    PhotoPreviewView(
                        photo: photo.image,
                        onSave: { savedPhoto in
                            if let index = selectedPhotos.firstIndex(of: photo) {
                                selectedPhotos[index] = IdentifiableImage(image: savedPhoto)
                            }
                            isPreviewingPhoto = false
                        },
                        onEdit: { editedPhoto in
                            if let index = selectedPhotos.firstIndex(of: photo) {
                                selectedPhotos[index] = IdentifiableImage(image: editedPhoto)
                            }
                            isPreviewingPhoto = false
                        }
                    )
                    .toolbar(.hidden, for: .tabBar)
                }
            }
            .sheet(isPresented: $isPhotoPickerPresented) {
                PhotoPicker(selectedImages: $selectedPhotos)
            }
            .onDisappear {
                stopMusic()
            }
        }
    }
    
    func handleCapturedImage() {
        guard let photo = capturedImage, !isImageProcessed else { return }
        isImageProcessed = true
        
        if selectedPhotos.contains(where: { $0.image.pngData() == photo.pngData() }) {
            print("Photo already exists")
            return
        }
        
        let identifiablePhoto = IdentifiableImage(image: photo)
        selectedPhotos.append(identifiablePhoto)
        
        let latitude = locationManager.lastKnownlocation?.coordinate.latitude
        let longitude = locationManager.lastKnownlocation?.coordinate.longitude
        
        let newItem = Item(
            timestamp: Date(),
            photoData: photo.jpegData(compressionQuality: 0.8),
            latitude: latitude,
            longitude: longitude
        )
        
        modelContext.insert(newItem)
        
        editingPhoto = identifiablePhoto
        isPreviewingPhoto = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            capturedImage = nil
            isPresented = false
            isImageProcessed = false
        }
    }
    
    func toggleMusicPlayback() {
        if isPlaying {
            stopMusic()
        } else if let musicName = selectedMusic {
            playMusic(named: musicName)
        } else {
            print("No music selected")
        }
    }
    
    func playMusic(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Music not found: \(name)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = Float(volume / 100)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Music playback error: \(error.localizedDescription)")
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func resetCamera() {
        capturedImage = nil
        isPreviewingPhoto = false
    }
    
    func savePhotoToAlbum(_ photo: UIImage) {
        guard let photoData = photo.jpegData(compressionQuality: 1.0) else { return }
        
        let request = FetchDescriptor<Item>()
        
        do {
            let existingItems: [Item] = try modelContext.fetch(request)
            
            if existingItems.contains(where: { $0.photoData == photoData }) {
                print("Photo already exists in the album.")
                return
            }
            
            let newItem = Item(
                timestamp: Date(),
                photoData: photoData,
                latitude: locationManager.lastKnownlocation?.coordinate.latitude,
                longitude: locationManager.lastKnownlocation?.coordinate.longitude
            )
            
            modelContext.insert(newItem)
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CameraView()
}
