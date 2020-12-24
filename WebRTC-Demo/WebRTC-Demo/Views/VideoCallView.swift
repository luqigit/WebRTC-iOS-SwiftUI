//
//  VideoCallView.swift
//  WebRTC-Demo
//
//  Created by luqi on 2020/12/24.
//

import SwiftUI

struct VideoCallView: View {
    @ObservedObject var viewModel = VideoCallViewModel()
    @State var room :String
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VideoView(videoTrack: self.viewModel.localVideoTrack,refreshVideoTrack: Binding<Bool>(get: {return self.viewModel.refreshLocalVideoTrack},
                                                                                                      set: { p in self.viewModel.refreshLocalVideoTrack = p}));
                VideoView(videoTrack: self.viewModel.remoteVideoTrack,refreshVideoTrack: Binding<Bool>(get: {return self.viewModel.refreshRemoteVideoTrack},
                                                                                                      set: { p in self.viewModel.refreshRemoteVideoTrack = p}));
            }
        }
        .navigationBarTitle(Text("123"), displayMode: .inline)
        .onAppear(perform: {
            self.viewModel.connectRoom(roomID: self.room);
        })
//        VStack{
//            DetailVideoCallView();
//            DetailVideoCallView();
//        }
    }
}

struct DetailVideoCallView: View {
    var body: some View {
        Text("详情页")
    }
}

struct VideoCallView_Previews: PreviewProvider {
    static var previews: some View {
        VideoCallView(room:"123456")
    }
}
