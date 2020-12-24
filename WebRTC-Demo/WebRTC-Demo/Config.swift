//
//  Config.swift
//  AppRTCMacSwiftUIDemo
//
//  Created by luqi on 2020/12/20.
//

import Foundation

fileprivate let defaultIceServers = ["stun:stun.l.google.com:19302",
                                     "stun:stun1.l.google.com:19302",
                                     "stun:stun2.l.google.com:19302",
                                     "stun:stun3.l.google.com:19302",
                                     "stun:stun4.l.google.com:19302"]

fileprivate let defaultSignalingServer = "https://appr.tc"

struct Config {
    let signalingServer: String
    let webRTCIceServers: [String]
    
    static let `default` = Config(signalingServer: defaultSignalingServer,
                                  webRTCIceServers: defaultIceServers)
}
