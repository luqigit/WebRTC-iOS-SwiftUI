//
//  VideoView.swift
//  WebRTC-Demo
//
//  Created by luqi on 2020/12/23.
//

import SwiftUI
import WebRTC

struct VideoView: UIViewRepresentable {
    let videoTrack: RTCVideoTrack?
    @Binding var refreshVideoTrack: Bool
    //RTCNSGLVideoView
    //RTCMTLNSVideoView
    func makeUIView(context: Context) -> RTCMTLVideoView {
        let view = RTCMTLVideoView(frame: .zero)
        view.videoContentMode = .scaleAspectFit
        return view
    }

    func updateUIView(_ view: RTCMTLVideoView, context: Context) {
        if(refreshVideoTrack){
            videoTrack?.add(view)
            refreshVideoTrack = false
        }

    }
    
//        func makeUIView(context: Context) -> UIView {
//            let view = UIView(frame: .zero)
//            return view
//        }
//    
//        func updateUIView(_ view: UIView, context: Context) {
//            if(refreshVideoTrack){
//                refreshVideoTrack = false
//            }
//    
//        }
    
}
