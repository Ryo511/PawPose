//
//  HomeView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2024/12/11.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    let groupedItems = Dictionary(grouping: items) { item in
                        Calendar.current.startOfDay(for: item.timestamp)
                    }
                    
                    ForEach(groupedItems.keys.sorted(), id: \.self) { date in
                        VStack(alignment: .leading) {
                            Text(formatDate(date))
                                .font(.headline)
                                .padding(.leading)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(groupedItems[date] ?? []) { item in
                                        NavigationLink(destination: PhotoDetailView(item: item, deleteAction: deleteItem)) {
                                            if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 150, height: 150)
                                                    .cornerRadius(15)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
    }
    
    private func deleteItem(_ item: Item) {
        DispatchQueue.main.async {
            withAnimation {
                modelContext.delete(item)
                try? modelContext.save()
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年MM月dd日 (E)"
        
        return formatter.string(from: date)
    }
}

struct PhotoDetailView: View {
    let item: Item
    var deleteAction: (Item) -> Void
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack {
                if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
//                        .frame(maxWidth: 300, maxHeight: 300)
                        .cornerRadius(20)
                }

                if isEditing {
                    Button(action: {
                        deleteAction(item)
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                    }
                    .padding(5)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditing.toggle() }) {
                    Text(isEditing ? "Done" : "Edit")
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
