# WebRTC Demo for ios 
使用 swiftui 实现 webrtc demo for ios 
实现 聊天 滤镜

## 使用说明
  1. 自行编译 GPUImage3(https://github.com/BradLarson/GPUImage3)
  1. 可以修改config中的服务器地址

## 自己假设服务器
  使用 WebRTC-Docker (https://github.com/Piasy/WebRTC-Docker)
```
    docker run --rm \
    -p 8080:8080 -p 8089:8089 -p 3478:3478 -p 3478:3478/udp -p 3033:3033 \
    -p 64152-64999:64152-64999/udp \
    -e PUBLIC_IP=<your-ip-address>\
    --ulimit nofile=5000:5000 \
    -it piasy/apprtc-server
```
## 环境

  Mac OS 10.15

  XCode 12.3
 
 ## TODO
- [x] 添加 滤镜
- [ ] 切换 滤镜
- [ ] 控制 音频发送 和 视频发送

