//
//  WebSocketClient.swift
//  SwiftWebSocketClientSample
//
//  Created by Akira Shimizu on 2020/12/05.
//

import Foundation
import SwiftUI

class WebSocketClient: NSObject, ObservableObject {
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    @Published var messages: [String] = []
    @Published var isConnected: Bool = false
    
    func setup(url: String) {
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = urlSession.webSocketTask(with: URL(string: url)!)
    }
    
    func connect() {
        webSocketTask?.resume()
        receive()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func send(_ message: String) {
        let msg = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(msg) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    private func receive() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text message: \(text)")
                    DispatchQueue.main.async {
                        self?.messages.append(text)
                    }
                case .data(let data):
                    if let stringData = String(data: data, encoding: .utf8) {
                        print("Received binary message: \(stringData)")
                    } else {
                        print("Received binary message that could not be converted to String")
                    }
                @unknown default:
                    fatalError()
                }
                self?.receive()
            case .failure(let error):
                print("Failed to receive message: \(error)")
            }
        }
    }
}

extension WebSocketClient: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("didOpenWithProtocol")
        DispatchQueue.main.async {
            self.isConnected = true
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("didCloseWith: closeCode: \(closeCode) reason: \(String(describing: reason))")
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("didCompleteWithError error: \(String(describing: error))")
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
}
