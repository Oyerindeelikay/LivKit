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

    // GRACE / FALLBACK: initialize video player
    if ((widget.type == "grace" || widget.type == "fallback") &&
        widget.videoUrl != null &&
        widget.videoUrl!.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.videoUrl!)
        ..initialize().then((_) {
          if (!mounted) return;
          _controller!.setLooping(true);
          _controller!.play();
          setState(() {});
        });
    }

    // LIVE: initialize Agora mini preview
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
    await _engine!.setClientRole(role: ClientRoleType.clientRoleAudience);

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine!.joinChannel(
      token: widget.agoraToken!,
      channelId: widget.channelName!,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    setState(() => _engineReady = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    if (_engineReady && _engine != null) {
      _engine!.leaveChannel();
      _engine!.release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // LIVE: show mini Agora view
    if (widget.type == "live") {
      if (_engineReady && _remoteUid != null) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine!,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: widget.channelName!),
          ),
        );
      } else {
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Text(
            "LIVE",
            style: TextStyle(color: Colors.redAccent, fontSize: 18),
          ),
        );
      }
    }

    // GRACE / FALLBACK: video player
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

    // No video available
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Text(
        widget.type == "grace" ? "STREAM ENDED" : "LOADING...",
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
