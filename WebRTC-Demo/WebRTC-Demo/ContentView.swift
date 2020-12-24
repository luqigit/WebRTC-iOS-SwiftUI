//
//  ContentView.swift
//  WebRTC-Demo
//
//  Created by luqi on 2020/12/23.
//

import SwiftUI
import Combine

//struct ContentView: View {
//    @State private var roomNumber: String = ""
//    let detail = Detail()
//    var body: some View {
//        //VStack{
//            //TextField("请输入房间号", text: $roomNumber)
////            Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
////                Text("CallRoom")
////            }
//            NavigationLink(destination: Detail()) {
//                Text("跳转")
//            }
//        //}
//    }
//}

struct ContentView: View {
    @State private var isShowingDetailView = false
    @State private var roomNumber: String = ""
    @State private var showAlert = false
    var body: some View {
        NavigationView{
            VStack {
                NavigationLink(destination:
                                VideoCallView(room:self.roomNumber), isActive: $isShowingDetailView) {
                    EmptyView();
                }
                .foregroundColor(.green)
                .background(Color.yellow)
                
                HStack{
                    Spacer();
                    TextField("请输入房间号", text: $roomNumber)
                        .keyboardType(.numberPad)
                        .onReceive(Just(roomNumber)) { newValue in
                                        let filtered = newValue.filter { "0123456789".contains($0) }
                                            if filtered != newValue {
                                                self.roomNumber = filtered
                                        }
                                }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width:200)
                    Button("Join") {
                        if(self.roomNumber.count >= 6){
                            self.isShowingDetailView = true
                        }else{
                            self.showAlert = true
                        }

                    }.alert(isPresented: $showAlert, content: {
                        Alert(title: Text("warning "),
                              message: Text("room name must be more 6 numbers"),
                              dismissButton: .default(Text("Got it!")))
                    })
 
                    Spacer();
                }
                

                
                Spacer()
            }.navigationTitle("WebRTC Demo")
        }
    }
}

struct Detail: View {
    var body: some View {
        Text("详情页")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
