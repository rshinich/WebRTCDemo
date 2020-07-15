//
//  SignalingClient.swift
//  WebRTCDemo
//
//  Created by 张忠瑞 on 2020/6/12.
//  Copyright © 2020 张忠瑞. All rights reserved.
//

import Foundation
import WebRTC


protocol SignalClientDelegate: class {

    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)

}

final class SignalingClient {

    //MARK: - Property

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let webSocket: StarscreamWebSocket
    weak var deleagte: SignalClientDelegate?

    //MARK: - Implementation

    init(webSocket: StarscreamWebSocket) {
        self.webSocket = webSocket
    }

    func connect() {
        self.webSocket.delegate = self
        self.webSocket.connect()
    }

    func send(sdp rtcSdp: RTCSessionDescription) {

        let message = Message.sdp(SessionDescription(from: rtcSdp))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode sdp: \(error)")

        }
    }

    func send(candidate rtcIceCandiatet: RTCIceCandidate) {
        let message = Message.candidate(IceCandidate(from: rtcIceCandiatet))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
    }
}

extension SignalingClient: StarscreamWebSocketDelegate {

    func webSocketDidConnect(_ websocket: StarscreamWebSocket) {
        self.deleagte?.signalClientDidConnect(self)
    }

    func webSocketDidDisconnect(_ websocket: StarscreamWebSocket) {
        self.deleagte?.signalClientDidDisconnect(self)
    }

    func webSocket(_ webSocket: StarscreamWebSocket, didReceiveData data: Data) {
        let message: Message
        do {
            message = try self.decoder.decode(Message.self, from: data)
        }
        catch {
            debugPrint("Warning: Could not decode incoming message: \(error)")
            return
        }

        switch message {
        case .candidate(let iceCandidate):
            self.deleagte?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp(let sessionDescription):
            self.deleagte?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
        }

    }


}
