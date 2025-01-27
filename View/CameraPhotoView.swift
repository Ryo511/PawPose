//
//  CameraPhotoView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2024/12/25.
//

import SwiftUI
import PhotosUI

struct IdentifiableImage: Identifiable, Hashable {
    let id = UUID()
    let image: UIImage
}

struct CameraPhotoView: View {
    @State private var selectedPhotos: [IdentifiableImage] = []
    @State private var isPhotoPickerPresented: Bool = false
    @State private var editingPhoto: IdentifiableImage? = nil
    
    var body: some View {
        VStack {
            if selectedPhotos.isEmpty {
                Text("No photos selected")
                    .foregroundColor(.gray)
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(selectedPhotos) { photo in
                            Image(uiImage: photo.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .onTapGesture {
                                    editingPhoto = photo
                                }
                        }
                    }
                }
                .padding()
            }
            
            Button("Select Photos") {
                isPhotoPickerPresented = true
            }
            .padding()
        }
        .sheet(isPresented: $isPhotoPickerPresented) {
            PhotoPicker(selectedImages: $selectedPhotos)
        }
        .onAppear {
            // 刷新地圖視圖
            // 這裡可以添加代碼來刷新地圖視圖
        }
    }
}

struct PhotoEditorView: View {
    var photo: UIImage
    var onSave: (UIImage) -> Void
    @State private var sticker: String = ""
    @State private var position: CGSize = .zero
    
    var body: some View {
        ZStack {
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if !sticker.isEmpty {
                Text(sticker)
                    .font(.largeTitle)
                    .position(x: UIScreen.main.bounds.width / 2 + position.width,
                              y: UIScreen.main.bounds.height / 2 + position.height)
                    .gesture(DragGesture()
                        .onChanged { value in
                            position = value.translation
                        }
                    )
            }
            
//            VStack {
//                Spacer()
//                TextField("Enter Sticker Text", text: $sticker)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                Button("Save") {
//                    onSave(photo) // 保存編輯後的照片
//                }
//                .padding()
//            }
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [IdentifiableImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            let imageResults = results.compactMap { result -> IdentifiableImage? in
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    var loadedImage: UIImage?
                    let semaphore = DispatchSemaphore(value: 0)
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                        if let image = object as? UIImage {
                            loadedImage = image
                        }
                        semaphore.signal()
                    }
                    semaphore.wait()
                    if let loadedImage = loadedImage {
                        return IdentifiableImage(image: loadedImage)
                    }
                }
                return nil
            }
            parent.selectedImages.append(contentsOf: imageResults)
        }
    }
}

#Preview {
    CameraPhotoView()
}
