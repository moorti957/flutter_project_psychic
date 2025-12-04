import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

const String agoraAppId = "56617857dfa44398aabb3309bd366fa2"; // replace if different

class CallScreen extends StatefulWidget {
  final String roomId;
  const CallScreen({super.key, required this.roomId});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late RtcEngine engine;
  int? remoteUid;
  bool muted = false;
  bool cameraOff = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.camera, Permission.microphone].request();

    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: agoraAppId));

    engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        debugPrint('Local joined channel ${connection.channelId}');
      },
      onUserJoined: (connection, uid, elapsed) {
        debugPrint('Remote joined $uid');
        setState(() { remoteUid = uid; });
      },
      onUserOffline: (connection, uid, reason) {
        debugPrint('Remote left $uid');
        setState(() { remoteUid = null; });
      },
    ));

    await engine.enableVideo();
    await engine.startPreview();

    // join channel with roomId (use empty token for test if your project allows)
    await engine.joinChannel(
      token: "",
      channelId: widget.roomId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    try {
      engine.leaveChannel();
      engine.release();
    } catch (_) {}
    super.dispose();
  }

  void toggleMute() {
    setState(() => muted = !muted);
    engine.muteLocalAudioStream(muted);
  }

  void toggleCamera() {
    setState(() => cameraOff = !cameraOff);
    engine.muteLocalVideoStream(cameraOff);
  }

  void switchCamera() {
    engine.switchCamera();
  }

  void endCall() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text('Room: ${widget.roomId}'), backgroundColor: const Color(0xFF540E80)),
        body: Stack(
            children: [
              Center(
                child: remoteUid != null
                    ? AgoraVideoView(controller: VideoViewController.remote(rtcEngine: engine, canvas: VideoCanvas(uid: remoteUid), connection: RtcConnection(channelId: widget.roomId)))
                    : const Text('Waiting for user...', style: TextStyle(color: Colors.white)),
              ),
              Positioned(
                right: 16, top: 16, width: 120, height: 160,
                child: cameraOff
                    ? Container(color: Colors.grey[900], child: const Center(child: Icon(Icons.videocam_off, color: Colors.white)))
                    : AgoraVideoView(controller: VideoViewController(rtcEngine: engine, canvas: const VideoCanvas(uid: 0))),
              ),
              Positioned(
                bottom: 24, left: 0, right: 0,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  FloatingActionButton(
                    backgroundColor: muted ? Colors.red : Colors.white,
                    onPressed: toggleMute,
                    child: Icon(muted ? Icons.mic_off : Icons.mic, color: muted ? Colors.white : Colors.black),
                  ),
                  FloatingActionButton(backgroundColor: Colors.red, onPressed: endCall, child: const Icon(Icons.call_end, color: Colors.white)),
                  FloatingActionButton(backgroundColor: cameraOff ? Colors.red : Colors.white, onPressed: toggleCamera, child: Icon(cameraOff ? Icons.videocam_off : Icons.videocam, color: cameraOff ? Colors.white : Colors.black)),
                  FloatingActionButton(backgroundColor: Colors.white, onPressed: switchCamera, child: const Icon(Icons.cameraswitch, color: Colors.black)),
                ]),
              )
            ],
            ),
        );
    }
}