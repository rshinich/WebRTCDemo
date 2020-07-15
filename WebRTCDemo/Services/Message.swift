//
//  Message.swift
//  WebRTCDemo
//
//  Created by 张忠瑞 on 2020/6/12.
//  Copyright © 2020 张忠瑞. All rights reserved.
//

import Foundation

enum Message {
    case sdp(SessionDescription)
    case candidate(IceCandidate)
}

extension Message: Codable {
    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .sdp(let sessionDescription):
            try container.encode(sessionDescription, forKey: .payload)
            try container.encode(String(describing: SessionDescription.self), forKey: .type)
        case .candidate(let iceCandidate):
            try container.encode(iceCandidate, forKey: .payload)
            try container.encode(String(describing: IceCandidate.self), forKey: .type)
        }
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case String(describing: SessionDescription.self):
            self = .sdp(try container.decode(SessionDescription.self, forKey: .payload))
        case String(describing: IceCandidate.self):
            self = .candidate(try container.decode(IceCandidate.self, forKey: .payload))
        default:
            throw DecodeError.unknowType
        }
    }


    enum DecodeError: Error {
        case unknowType
    }

    enum CodingKeys: String, CodingKey {
        case type, payload
    }

}
