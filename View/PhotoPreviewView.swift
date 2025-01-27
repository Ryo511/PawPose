//
//  PhotoPreviewView.swift
//  PawPose
//
//  Created by OLIVER LIAO on 2024/12/19.
//
import SwiftUI
import PhotosUI
import SwiftData

struct PhotoPreviewView: View {
    let photo: UIImage
    var onSave: (UIImage) -> Void
    var onEdit: (UIImage) -> Void
    let achievementDate = Date.now
    @ObservedObject var locationManager = LocationManager()
    @Environment(\.modelContext) var modelContext
    @State private var selectedstamp: String?
    @State private var showStampSheet = false
    @State private var texts: [TextItems] = []
    @State private var editText: TextItems?
    @State private var string = ""
    @State private var stringbtn = false
    @State private var textColor = Color.white
    @State private var stamps: [Stamp] = []
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var lastOffset: CGSize = .zero
    @State private var draggingStampIndex: Int?
    @State private var initialPosition: CGPoint?
    @State private var textPosition: CGPoint = CGPoint(x: 150, y: 150)
    @State private var textSize: CGFloat = 24
    @State private var isDeleteMode = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = max(1.0, min(lastScale * value, 5.0))
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                }
                        )
                    
                    Text(string)
                            .font(.system(size: textSize))
                            .foregroundColor(textColor)
                            .position(textPosition)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        textPosition = value.location
                                    }
                            )
                    
                    ForEach(stamps.indices, id: \.self) { index in
                        Text(stamps[index].name)
                            .font(.system(size: stamps[index].size))
                            .position(stamps[index].position)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if draggingStampIndex == nil {
                                            draggingStampIndex = index
                                            initialPosition = stamps[index].position
                                        }
                                        if let startPosition = initialPosition {
                                            stamps[index].position = CGPoint(
                                                x: startPosition.x + value.translation.width,
                                                y: startPosition.y + value.translation.height
                                            )
                                        }
                                    }
                                    .onEnded { _ in
                                        draggingStampIndex = nil
                                        initialPosition = nil
                                    }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let newSize = max(50, min(stamps[index].size * value, 300))
                                        stamps[index].size = newSize
                                    }
                            )
                            .onTapGesture {
                                if isDeleteMode {
                                    deleteStamp(at: index)
                                    isDeleteMode = false
                                }
                            }
                    }
                    
                    ForEach(texts.indices, id: \.self) { index in
                        Text(texts[index].text)
                            .font(.title)
                            .foregroundColor(texts[index].color)
                            .offset(texts[index].offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        texts[index].offset = value.translation
                                    }
                            )
                            .onTapGesture {
                                editText(texts[index])
                            }
                    }
                }
                
                Spacer()
                
                VStack {
                    Text(achievementDate.formatted())
                    
                    if stringbtn {
                        VStack {
                            TextField("输入文字", text: $string, onCommit: addText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                        }
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("完成") {
                                    UIApplication.shared.endEditing()
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Button(action: {
                            stringbtn.toggle()
                        }) {
                            Image(systemName: "textformat.size.smaller")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        
                        Button(action: {
                            showStampSheet = true
                        }) {
                            Image(systemName: "face.dashed.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .sheet(isPresented: $showStampSheet) {
                            StampListView(stamp: $selectedstamp)
                        }
                        .onChange(of: selectedstamp) { _, newValue in
                            if let newStamp = newValue {
                                stamps.append(Stamp(name: newStamp, position: CGPoint(x: 150, y: 150)))
                                selectedstamp = nil
                            }
                        }
                        
                        Button(action: {
                            isDeleteMode.toggle()
                        }) {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(isDeleteMode ? .red : .black)
                        }
                        
                        Button("保存") {
                            saveEditedPhoto()
                        }
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private func deleteStamp(at index: Int) {
        stamps.remove(at: index)
    }
    
    private func editText(_ textitem: TextItems) {
        editText = textitem
    }
    
    private func addText() {
        if !string.isEmpty {
            let newTextItem = TextItems(text: string, color: textColor, offset: .zero)
            texts.append(newTextItem)
            string = ""
            stringbtn = false
        }
    }
    
    private func saveEditedPhoto() {
        let renderer = ImageRenderer(content: ZStack {
            Color.white
            
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.75)
            
            ForEach(stamps) { stamp in
                Text(stamp.name)
                    .font(.system(size: stamp.size))
                    .position(stamp.position)
            }
            
            ForEach(texts) { textItem in
                Text(textItem.text)
                    .font(.title)
                    .foregroundColor(textItem.color)
                    .offset(textItem.offset)
            }
        })
        
        if let editedImage = renderer.uiImage {
            if let photoData = editedImage.jpegData(compressionQuality: 1.0) {
                
                let latitude = locationManager.lastKnownlocation?.coordinate.latitude
                let longitude = locationManager.lastKnownlocation?.coordinate.longitude
                
                let newItem = Item(timestamp: Date(),
                                   photoData: photoData,
                                   latitude: latitude,
                                   longitude: longitude)
                
                
                modelContext.insert(newItem)
                onSave(editedImage)
                
            } else {
                print("无法生成照片数据")
            }
        } else {
            print("渲染失败")
        }
    }
}

struct TextItems: Identifiable {
    let id = UUID()
    var text: String
    var color: Color
    var offset: CGSize
}

struct Stamp: Identifiable {
    let id = UUID()
    var name: String
    var position: CGPoint
    var size: CGFloat = 100
}


struct StampListView: View {
    @Binding var stamp: String?
    @Environment(\.presentationMode) var presentationMode
    var stampSet = ["🫶🏼", "👹", "🤡", "😻", "🫷🏼", "🫸🏼", "🤌🏼", "🫴🏼", "🐶", "🐻‍❄️", "🐮", "🙉", "🙊", "🐽", "🐷", "🐸", "🐣", "🐤", "🦉", "🇯🇵", "💴", "👺", "🍡", "🗾", "🎌", "🍣", "🍘", "🎏", "🇰🇷", "🇭🇰", "🦴", "🥥", "🫐", "🥑", "🥨", "🍓", "🍇", "🍒", "🍑", "🍍", "🍊", "🍋", "🍉", "🍈", "🍏", "🍎", "🍌", "🍐", "🍅", "🍆", "🥦", "🥬", "🥒", "🌶", "🫑", "🌽", "🥕", "🫒", "🧄", "🧅", "🍠", "🥔", "🥖", "🥯", "🥐", "🍞", "🥞", "🧇", "🧀", "🍖", "🍗", "🥩", "🥓", "🍔", "🍟", "🍕", "🌭", "🥪", "🌮", "🌯", "🫔", "🥙", "🧆", "🥚", "🍳", "🥘", "🍲", "🫕", "🥣", "🥗", "🍿", "🧈", "🧂", "🥫", "🍱", "🍘", "🎏", "🍢", "🈵", "🈲", "㊗️", "📿", "🇺🇸", "🇹🇼", "🇰🇷", "🇭🇰", "🦴", "🥥", "🫐", "🥑", "🥨", "🍓", "🍇", "🍒", "🍑", "🍍", "🍊", "🍋", "🍉", "🍈", "🍏", "🍎", "🍌", "🍐", "🍅", "🍆", "🥦", "🥬", "🥒", "🌶", "🫑", "🌽", "🥕", "🫒", "    🧄", "🧅", "🍠", "🥔", "🥖", "🥯", "🥐", "🍞", "🥞", "🧇", "🧀", "🍖", "🍗", "🥩", "🥓", "🍔", "🍟", "🍕", "🌭", "🥪", "🌮"]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                ForEach(stampSet, id: \.self) { stamp in
                    Text(stamp)
                        .font(.largeTitle)
                        .frame(width: 80, height: 80)
                        .onTapGesture {
                            self.stamp = stamp
                            presentationMode.wrappedValue.dismiss()
                        }
                }
            }
        }
        .padding()
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    PhotoPreviewView(photo: UIImage(named: "sample")!, onSave: { _ in }, onEdit: { _ in })
}
