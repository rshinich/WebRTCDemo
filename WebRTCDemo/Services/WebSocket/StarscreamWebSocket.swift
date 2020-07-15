//
//  StarscreamWebSocket.swift
//  WebRTCDemo
//
//  Created by 张忠瑞 on 2020/6/12.
//  Copyright © 2020 张忠瑞. All rights reserved.
//

import UIKit
import Starscream

protocol StarscreamWebSocketDelegate: class {

    func webSocketDidConnect(_ websocket: StarscreamWebSocket)
    func webSocketDidDisconnect(_ websocket: StarscreamWebSocket)
    func webSocket(_ webSocket: StarscreamWebSocket, didReceiveData data: Data)
}

class StarscreamWebSocket: NSObject {

    var delegate: StarscreamWebSocketDelegate?
    private let socket: WebSocket

    init(url: URL) {

        self.socket = WebSocket(url: url)

        super.init()

        self.socket.delegate = self


    }

    func connect() {
        self.socket.connect()
    }

    func send(data: Data) {
        self.socket.write(data: data)
    }
}

extension StarscreamWebSocket: Starscream.WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        self.delegate?.webSocketDidConnect(self)
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.delegate?.webSocketDidDisconnect(self)
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        self.delegate?.webSocket(self, didReceiveData: data)
    }
}
