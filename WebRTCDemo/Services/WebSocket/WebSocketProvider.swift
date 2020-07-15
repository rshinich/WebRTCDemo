//
//  WebSocketProvider.swift
//  WebRTCDemo
//
//  Created by 张忠瑞 on 2020/6/12.
//  Copyright © 2020 张忠瑞. All rights reserved.
//

// 苹果在iOS13中提供了新的Api NSURLSessionWebSocketTask以实现原生的WebSocket连接。
// 所以，在iOS13+的环境下，我们直接使用原生的WebSocket模块
// https://developer.apple.com/documentation/foundation/nsurlsessionwebsockettask?language=objc

import Foundation

protocol WebSocketProviderDelegate: class {
    func webSocketDidConnect(_ websocket: WebSocketProvider)
    func webSocketDidDisconnect(_ websocket: WebSocketProvider)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data)
}

protocol WebSocketProvider: class {
    
    var delegate: WebSocketProviderDelegate? { get set }
    func connect()
    func send(data: Data)
}

