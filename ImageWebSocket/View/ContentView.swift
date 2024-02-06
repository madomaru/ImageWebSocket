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

    init(){
        client = WebSocketClient()
        client.setup(url: "wss://websocket-image-server-toman.glitch.me")
    }
    
    var body: some View {
        VStack {
            Spacer()
            // space to show recieve from server.
            if client.isConnected{
                List{
                    ForEach(client.messages, id: \.self){message in
                        Text(message)
                    }
                }
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
            )
            Spacer()
            Text(" ↓ Received Image")
                .font(.title)
            Image("SampleImg")
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
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
}

#Preview {
    ContentView()
}


