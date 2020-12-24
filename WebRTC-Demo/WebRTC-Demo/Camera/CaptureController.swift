//
//  CaptureController.swift
//  AppRTCMacSwiftUIDemo
//
//  Created by luqi on 2020/12/21.
//

import Foundation
import WebRTC
import GPUImage

protocol CameraCaptureDelegate: class {
    func captureVideoOutput(_ videoFrame: RTCVideoFrame)
}

class CaptureController: NSObject {
    weak var delegate: CameraCaptureDelegate?
    public let sources = SourceContainer()
    public let maximumInputs:UInt = 1

    var _videoCapturer:RTCCameraVideoCapturer?

    var camera:Camera!
    var filter:SmoothToonFilter!
    
    var pictureOutput = PictureOutput()
    var movieOutput:MovieOutput? = nil
    
    var timeNS:Int64 = 0;
    init(_ rtcCameraVC: RTCCameraVideoCapturer?) {
        super.init();
        _videoCapturer = rtcCameraVC
    }
        
    func startCapture() -> Void {
        
        do {
            camera = try Camera(sessionPreset: .vga640x480, cameraDevice: nil, location: PhysicalCameraLocation.frontFacing, orientation: nil, captureAsYUV: true)
            filter = SmoothToonFilter()

            camera --> filter --> pictureOutput
            //camera --> self
            camera.delegate = self
            camera.runBenchmark = false
            camera.startCapture()
                        
            pictureOutput.onlyCaptureNextFrame = false
            pictureOutput.imageAvailableCallback = {[weak self]image in
                let pixelBuffer: CVPixelBuffer? = image.buffer();
                let rtcpixelBuffer = RTCCVPixelBuffer(pixelBuffer: pixelBuffer!)
                let timeStampNs: Int64 = Int64(CACurrentMediaTime() * Double(NSEC_PER_SEC))
                let videoFrame = RTCVideoFrame(buffer: rtcpixelBuffer, rotation: RTCVideoRotation._0, timeStampNs: timeStampNs)
                self?.delegate?.captureVideoOutput(videoFrame)
            }
            
        } catch {
            fatalError("Couldn't initialize pipeline, error: \(error)")
        }


    }
    
    func stopCapture() -> Void {
        camera.stopCapture()
    }
    
}

extension CaptureController: CameraDelegate {

    func didCaptureBuffer(_ sampleBuffer: CMSampleBuffer){
//        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
//            let rtcpixelBuffer = RTCCVPixelBuffer(pixelBuffer: pixelBuffer)
//            print("height",height)
//            let timeStampNs: Int64 = Int64(CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) * 1000000000)
//            self.timeNS = timeStampNs
//            let videoFrame = RTCVideoFrame(buffer: rtcpixelBuffer, rotation: RTCVideoRotation._90, timeStampNs: timeStampNs)
//
//            delegate?.captureVideoOutput(videoFrame)
//        }
    }
}
