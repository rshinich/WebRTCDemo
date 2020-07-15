//
//  NativeWebSocket.swift
//  WebRTCDemo
//
//  Created by 张忠瑞 on 2020/6/12.
//  Copyright © 2020 张忠瑞. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class NativeWebSocket: NSObject, WebSocketProvider {

    //MARK: - Property
    var delegate: WebSocketProviderDelegate?
    private let url: URL
    private var socket: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)


    //MARK: - Implementation

    init(url: URL) {
        self.url = url
        super.init()
    }

    //MARK: - Protcol method

    func connect() {

        let socket = self.urlSession.webSocketTask(with: self.url)
        socket.resume()
        self.socket = socket
        self.readMessage()

    }

    func send(data: Data) {
        self.socket?.send(.data(data), completionHandler: { (_) in

        })
    }

    //MARK: - Private method

    private func readMessage() {

        self.socket?.receive(completionHandler: { (result) in

            switch result {
            case .success(.data(let data)):
                self.delegate?.webSocket(self, didReceiveData: data)
                self.readMessage()
            case .success:
                debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
                self.readMessage()
            case .failure(let error):
                debugPrint("Warning: Got error with read message \(error)")
                self.disconnect()
            }
        })
    }

    private func disconnect() {
        self.socket?.cancel()
        self.socket = nil
        self.delegate?.webSocketDidDisconnect(self)
    }
}

@available(iOS 13.0, *)
extension NativeWebSocket: URLSessionWebSocketDelegate, URLSessionDelegate {

    


}
