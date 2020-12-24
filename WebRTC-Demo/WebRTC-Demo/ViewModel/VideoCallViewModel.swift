//
//  VideoCallViewModel.swift
//  WebRTC-Demo
//
//  Created by luqi on 2020/12/24.
//

import Foundation
import WebRTC
import SwiftUI

//class VideoCallViewModel: ObservableObject {
//    var room : String = "";
//    @Published var remoteVideoTrack : RTCVideoTrack?
//    @Published var localVideoTrack : RTCVideoTrack?
//    @Published var refreshRemoteVideoTrack: Bool = false
//    @Published var refreshLocalVideoTrack: Bool = false
//
//    func connectRoom(room:String) -> Void {
//        self.room = room
//        print("aaaa")
//    }
//}


//
//  AppViewModel.swift
//  AppRTCMacSwiftUIDemo
//
//  Created by luqi on 2020/12/18.
//

import Foundation
import SwiftUI
import WebRTC

class VideoCallViewModel: ObservableObject {
    @Published var remoteVideoTrack : RTCVideoTrack?
    @Published var localVideoTrack : RTCVideoTrack?
    @Published var refreshRemoteVideoTrack: Bool = false
    @Published var refreshLocalVideoTrack: Bool = false
    
    
    var _roomClient:RoomClient?
    
// MARK: Room
    var _roomInfo: JoinResponseParam?

    // MARK: 信令
    var _webSocket: WebSocketClient?
    var _messageQueue = [String]()
    //MARK: WebRTC
    var _webRTCClient: WebRTCClient?
    
    //MARK:Camera
    var _captureController : CaptureController?
    
    
    func connectRoom(roomID:String) -> Void {
        dLog("connectToRoom");
        prepare();
        join(roomID:roomID)
    }
    
    private func prepare(){
        _roomClient = RoomClient();
        _webSocket = WebSocketClient();
        _webRTCClient = WebRTCClient();
        let tmpVideoCapturer = _webRTCClient?.videoCapturer;
        _captureController = CaptureController(tmpVideoCapturer);
        _captureController?.delegate = self
        _captureController?.startCapture()
        
        remoteVideoTrack = _webRTCClient?.remoteVideoTrack;
        localVideoTrack = _webRTCClient?.localVideoTrack;
        refreshRemoteVideoTrack = true
        refreshLocalVideoTrack = true
    }
    func clear() {
        _roomClient = nil
        _webRTCClient = nil
        _webSocket = nil
        _captureController?.stopCapture();
        _captureController = nil
        remoteVideoTrack = nil
        localVideoTrack = nil
        refreshRemoteVideoTrack = true
        refreshLocalVideoTrack = true
    }
}

//MARK: 网络
extension VideoCallViewModel{
    func join(roomID:String) -> Void {
        guard let _roomClient = _roomClient else {
            return
        }
        _roomClient.join(roomID: roomID, completion: {
            [weak self](_ response: JoinResponseParam?, _ error: Error?) -> Void in
                if let response = response {
                    self?._roomInfo = response
                    if let messages = response.messages {
                        self?._messageQueue.append(contentsOf: messages)
                        self?.drainMessageQueue()
                    }
                    self?.connectToWebSocket()
                } else if let error = error as? RoomResponseError,
                    error == .full {
                    return
                } else if let error = error {
                    dLog(error)
                    return
                }
            
        });
    }
    
    func disconnect() -> Void {
        guard let roomID = _roomInfo?.room_id,
            let userID = _roomInfo?.client_id,
            let roomClient = _roomClient,
            let webSocket = _webSocket,
            let webRTCClient = _webRTCClient else { return }
  
        roomClient.disconnect(roomID: roomID, userID: userID) { [weak self] in
            self?._roomInfo = nil
        }
        
        let message = ["type": "bye"]
        
        if let data = message.JSONData {
            webSocket.send(data: data)
        }
        webSocket.delegate = nil
        _roomInfo = nil
        
        webRTCClient.disconnect()
        
        clear()
    }
    
    func drainMessageQueue() {
        guard let webSocket = _webSocket,
            webSocket.isConnected,
            let webRTCClient = _webRTCClient else {
                return
        }
        
        for message in _messageQueue {
            processSignalingMessage(message)
        }
        _messageQueue.removeAll()
        webRTCClient.drainMessageQueue()
    }
    
    
    func processSignalingMessage(_ message: String) -> Void {
        guard let webRTCClient = _webRTCClient else { return }
        
        let signalMessage = SignalMessage.from(message: message)
        switch signalMessage {
        case .candidate(let candidate):
            webRTCClient.handleCandidateMessage(candidate)
            dLog("Receive candidate")
        case .answer(let answer):
            webRTCClient.handleRemoteDescription(answer)
            dLog("Recevie Answer")
        case .offer(let offer):
            webRTCClient.handleRemoteDescription(offer)
            dLog("Recevie Offer")
        case .bye:
            disconnect()
        default:
            break
        }
    }
    
    func sendSignalingMessage(_ message: Data) {
        guard let roomID = _roomInfo?.room_id,
            let userID = _roomInfo?.client_id,
            let roomClient = _roomClient else { return }
        
        roomClient.sendMessage(message, roomID: roomID, userID: userID) {
            
        }
    }
    
}

//MARK: webSocketClientDelegate
extension VideoCallViewModel: WebSocketClientDelegate{
    func connectToWebSocket() -> Void {
        guard let webSocketURL = self._roomInfo?.wss_url ,
              let url = URL(string: webSocketURL),
              let webSocket = _webSocket else {
            return
        }
        webSocket.delegate = self;
        webSocket.connect(url: url);
    }
    
    func registerWithCollider() {
        guard let roomID = _roomInfo?.room_id,
            let userID = _roomInfo?.client_id,
            let webSocket = _webSocket else {
                return
        }
        
        let message = ["cmd": "register",
                       "roomid": roomID,
                       "clientid": userID
        ]
        
        guard let data = message.JSONData else {
            debugPrint("Error in Register room.")
            return
        }
                
        webSocket.send(data: data)
        dLog("Register Room")
    }
    
    func webSocketDidConnect(_ webSocket: WebSocketClient) {
        guard let webRTCClient = _webRTCClient else { return }
        
        registerWithCollider();
        
        webRTCClient.delegate = self
        if(_roomInfo?.is_initiator == "true"){
            // 发送offer
            webRTCClient.offer()
        }
        drainMessageQueue();

    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketClient) {
        webSocket.delegate = nil
    }
    
    func webSocket(_ webSocket: WebSocketClient, didReceive data: String) {
        processSignalingMessage(data)
        _webRTCClient?.drainMessageQueue()
    }
    

}

//MARK: WebRTCClientDelegate
extension VideoCallViewModel: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, sendData data: Data) {
        sendSignalingMessage(data)
    }
}

//MARK: 音视频开关
extension VideoCallViewModel{

    
    func videoEnable(_ enable:Bool) -> Void {
        self._webRTCClient?.VideoIsEnable = enable
    }
    
    func audioEnable(_ enable:Bool) -> Void {
        self._webRTCClient?.AudioIsEnable = enable
    }

}


extension VideoCallViewModel: CameraCaptureDelegate {
    func captureVideoOutput(_ videoFrame: RTCVideoFrame){
        _webRTCClient?.didCaptureLocalFrame(videoFrame);
    }
}
