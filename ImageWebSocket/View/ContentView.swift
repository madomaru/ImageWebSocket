//
//  ContentView.swift
//  ImageWebSocket
//
//  Created by 伊藤まどか on 2024/01/29.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @ObservedObject var client: WebSocketClient
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State var tmpImage: UIImage? = nil
    
    init(){
        client = WebSocketClient()
        client.setup(url: "wss://websocket-image-server-toman.glitch.me")
    }
    
    var body: some View {
        VStack {
            Spacer()
            // space to show recieve from server.
            if client.isConnected{
                Text("接続済み")
            }else {
                Text("接続中")
            }
            
            // send button
            Button(action: {
                client.send("test")
            }, label: {
                Text("aと送る")
                    .font(.title)
            })
            Spacer()
            
            // photo picker
            PhotosPicker(
                selection: $selectedPhoto,
                label: {
                    Text("送る画像を選んでください")
                        .font(.title)
                }
            ).onChange(of: selectedPhoto){oldValue, pickedItem in
                
                Task {
                    // PickedItem → UIImageに変換
                    guard let imageData = try await pickedItem?.loadTransferable(type: Data.self) else {return}
                    guard let uiImage = UIImage(data: imageData) else {return}
                    
                    // UIImage→Base64に変換
                    guard let sendString = convertImageToBase64(uiImage) else {
                        print("can't convert UIImage to Base64")
                        return
                    }
                    guard let compressionImage = convertBase64ToImage(sendString) else {return}
                    tmpImage = compressionImage
                    
//                    client.send(sendString)
                }
                
                
                
            }
            Spacer()
            Text(" ↓ Received Image")
                .font(.title)
            if tmpImage != nil {
                Image(uiImage: tmpImage!)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal)
            }else{
                Image("SampleImg")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .onAppear(){
            client.connect()
        }
        .onDisappear(){
            client.disconnect()
        }
    }
    
    // UIImage→Base64に変換するメソッド
    private func convertImageToBase64(_ image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return nil }
        return imageData.base64EncodedString()
    }
    
    // Base64→UIImageに変換するメソッド
    private func convertBase64ToImage(_ base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: imageData)
    }
}

#Preview {
    ContentView()
}


