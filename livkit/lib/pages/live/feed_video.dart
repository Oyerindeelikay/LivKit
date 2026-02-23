import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../config/agora_config.dart';

class FeedVideo extends StatefulWidget {
  final String type; // live | grace | fallback
  final String? videoUrl;
  final String? channelName;
  final String? agoraToken;

  const FeedVideo({
    super.key,
    required this.type,
    this.videoUrl,
    this.channelName,
    this.agoraToken,
  });

  @override
  State<FeedVideo> createState() => _FeedVideoState();
}

class _FeedVideoState extends State<FeedVideo> {
  VideoPlayerController? _controller;
  RtcEngine? _engine;
  bool _engineReady = false;
  int? _remoteUid;

  @override
  void initState() {
    super.initState();

    // FALLBACK videos
    if (widget.type == "fallback" && widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.videoUrl!)
        ..initialize().then((_) {
          if (!mounted) return;
          _controller!.setLooping(true);
          _controller!.play();
          setState(() {});
        });
    }

    if (widget.type == "live" &&
        widget.channelName != null &&
        widget.agoraToken != null) {
      _initAgora();
    }
  }

  Future<void> _initAgora() async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      const RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );


    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() => _remoteUid = null);
        },
      ),
    );
    await _engine!.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine!.enableVideo();

    await _engine!.joinChannel(
      token: widget.agoraToken!,
      channelId: widget.channelName!,
      uid: 0,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        clientRoleType: ClientRoleType.clientRoleAudience,
      ),
    );

    setState(() => _engineReady = true);
  }

  @override
  void didUpdateWidget(covariant FeedVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If it becomes live and engine not started yet
    if (widget.type == "live" &&
        oldWidget.type != "live" &&
        widget.channelName != null &&
        widget.agoraToken != null &&
        _engine == null) {
      _initAgora();
    }

    // If it becomes fallback, dispose Agora
    if (widget.type != "live" && oldWidget.type == "live") {
      _engine?.leaveChannel();
      _engine?.release();
      _engine = null;
      _engineReady = false;
      _remoteUid = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    if (_engineReady && _engine != null) {
      _engine!.leaveChannel();
      _engine!.release();
    }

    _engineReady = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == "live") {
      if (_engineReady && _remoteUid != null) {
        return SizedBox.expand(
          child: AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine!,
              canvas: VideoCanvas(
                uid: _remoteUid,
                renderMode: RenderModeType.renderModeHidden,
              ),
              connection: RtcConnection(channelId: widget.channelName!),
            ),
          ),
        );
      } 
    }

    if (_controller != null && _controller!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Text(
        "LOADING...",
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
