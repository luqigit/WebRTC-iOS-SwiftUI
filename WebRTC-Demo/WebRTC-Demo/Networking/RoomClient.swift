//
//  RoomClient.swift
//  AppRTCMacSwiftUIDemo
//
//  Created by luqi on 2020/12/20.
//

import Foundation

enum JoinStatus: String, Decodable {
    case FULL
    case SUCCESS
}

struct JoinResponse: Decodable {
    let result: JoinStatus
    let params: JoinResponseParam
}

struct JoinResponseParam: Decodable {
    let room_id: String?
    let wss_url: String?
    let wss_post_url: String?
    let client_id: String?
    let is_initiator: String?
    let messages: [String]?
}

enum RoomResponseError: Error {
    case full
}

struct RoomClient {
    func join(roomID:String,completion: @escaping ((_ response: JoinResponseParam?, _ error: Error?) -> Void)) -> Void {
        var request = URLRequest(url: roomURL(roomID: roomID))
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request){(data, response, error) in
            guard let data = data else {
                if let error = error {
                    completion(nil, error)
                }
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let result = try decoder.decode(JoinResponse.self, from: data)
                
                if result.result == .SUCCESS {
                    completion(result.params, nil)
                } else if result.result == .FULL {
                    completion(nil, RoomResponseError.full)
                }
            }catch let error{
                completion(nil,error)
            }
            
        }
        
        task.resume();
    }
    
    func disconnect(roomID: String, userID: String, completion: @escaping (() -> Void)) {
        var request = URLRequest(url: leaveURL(roomID: roomID, userID: userID))
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { _,_,_  in
            completion()
        }
        
        task.resume()
    }
    
    func sendMessage(_ message: Data, roomID: String, userID: String, completion: @escaping (() -> Void)) {
        var request = URLRequest(url: messageURL(roomID: roomID, userID: userID))
        request.httpMethod = "POST"
        request.httpBody = message
        
        dLog("Message \(message.prettyPrintedJSONString)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error  in
            if let data = data {
                dLog("\(data.prettyPrintedJSONString)")
            } else if let error = error {
                dLog(error)
            }
            
            completion()
        }
        
        task.resume()
    }
    
}

// MARK: URL Path
extension RoomClient {
    func roomURL(roomID: String) -> URL {
        let base = Config.default.signalingServer + "/join/"
        return URL(string: base + "\(roomID)")!
    }
    func leaveURL(roomID: String, userID: String) -> URL {
        let base =  Config.default.signalingServer + "/leave/"
        return URL(string: base + "\(roomID)/\(userID)")!
    }
    func messageURL(roomID: String, userID: String) -> URL {
        let base =  Config.default.signalingServer + "/message/"
        return URL(string: base + "\(roomID)/\(userID)")!
    }
}
