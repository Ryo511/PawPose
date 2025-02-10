//
//  PhotoPickerView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2025/01/30.
//

import SwiftUI

struct PhotoPickerView: View {
    @Binding var selectedPhoto: UIImage? // 存儲選擇的照片
    let items: [Item] // 從 `HomeView` 獲取的照片
    @Binding var storedPhotoData: Data? // 存入 `AppStorage`，保持選擇的照片

    @Environment(\.dismiss) private var dismiss // 讓視圖能夠關閉

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("選擇一張照片")
                        .font(.headline)
                        .padding()

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(items) { item in
                            if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture {
                                        saveSelectedPhoto(uiImage) // ✅ 儲存選擇的照片
                                    }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("選擇照片")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss() // 讓使用者可以取消選擇
                    }
                }
            }
        }
    }

    /// 將選擇的 `UIImage` 轉換成 `Data` 並儲存
    private func saveSelectedPhoto(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            storedPhotoData = imageData // 存入 `AppStorage`
            selectedPhoto = image // 更新選擇的照片
            dismiss() // 關閉 `PhotoPickerView`
        }
    }
}
