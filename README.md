# rtsp_server

纯dart实现的rtsp服务器,目前仅支持TCP的方式推流以及播流

- [ ] UDP传输
- [x] TCP传输
- [x] H264视频流
- [x] AAC音频流
- [ ] 认证
- [ ] 部分错误处理

## 启动服务器

```dart
final server = RTSPServer(port: 8554);
server.start();
```

# 推流播流命令

* ffmpeg使用tcp循环推流视频文件

```bash
ffmpeg -v verbose -re -stream_loop -1 -i 视频文件 -c copy -f rtsp -rtsp_transport tcp rtsp://127.0.0.1:8554/live/test
```

* ffplay使用tcp播流

```bash
ffplay -v verbose -rtsp_transport tcp rtsp://127.0.0.1:8554/live/test
```
