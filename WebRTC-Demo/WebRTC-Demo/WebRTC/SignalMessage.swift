//
//  SignalMessage.swift
//  AppRTCMacSwiftUIDemo
//
//  Created by luqi on 2020/12/20.
//

import Foundation
import WebRTC


enum SignalMessage {
    case none
    case candidate(_ message: RTCIceCandidate)
    case answer(_ message: RTCSessionDescription)
    case offer(_ message: RTCSessionDescription)
    case bye
    
    static func from(message: String) -> SignalMessage {
        if let dict = message.convertToDictionary() {
            var messageDict: [String: Any]?

            if dict.keys.contains("msg") {
                let messageStr = dict["msg"] as? String
                messageDict = messageStr?.convertToDictionary()
            } else {
                messageDict = dict
            }
            
            if let messageDict = messageDict,
                let type = messageDict["type"] as? String {
                
                if type == "candidate",
                    let candidate = RTCIceCandidate.candidate(from: messageDict) {
                    return .candidate(candidate)
                } else if type == "answer",
                    let sdp = messageDict["sdp"] as? String {
                    return .answer(RTCSessionDescription(type: .answer, sdp: sdp))
                } else if type == "offer",
                    let sdp = messageDict["sdp"] as? String {
                    return .offer(RTCSessionDescription(type: .offer, sdp: sdp))
                } else if type == "bye" {
                    return .bye
                }
                
            }
        }
        return none
    }
}

extension RTCSessionDescription {
    func JSONData() -> Data? {
        let typeStr = RTCSessionDescription.string(for: self.type)
        let dict = ["type": typeStr,
                    "sdp": self.sdp]
        return dict.JSONData
    }
}

extension RTCIceCandidate {
    func JSONData() -> Data? {
        let dict = ["type": "candidate",
                    "label": "\(self.sdpMLineIndex)",
                    "id": self.sdpMid,
                    "candidate": self.sdp
        ]
        return dict.JSONData
    }

    static func candidate(from: [String: Any]) -> RTCIceCandidate? {
        let sdp = from["candidate"] as? String
        let sdpMid = from["id"] as? String
        let labelStr = from["label"] as? String
        let label = (from["label"] as? Int32) ?? 0
        
        return RTCIceCandidate(sdp: sdp ?? "", sdpMLineIndex: Int32(labelStr ?? "") ?? label, sdpMid: sdpMid)
    }
}
