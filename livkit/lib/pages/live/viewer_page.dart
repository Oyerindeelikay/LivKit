import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../config/agora_config.dart';
import '../../services/streaming_service.dart';
import '../../widgets/live_action.dart';
import '../../widgets/tiktok_comments.dart';

class ViewerPage extends StatefulWidget {
  final String streamId;
  final String accessToken;
  final String title;
  final String feedType; // live | grace

  const ViewerPage({
    super.key,
    required this.streamId,
    required this.accessToken,
    required this.title,
    required this.feedType,
  });

  @override
  State<ViewerPage> createState() => _ViewerPageState();

}

class _ViewerPageState extends State<ViewerPage>
    with WidgetsBindingObserver {
  final TextEditingController _commentController = TextEditingController();
  final TikTokCommentsController commentsController =
      TikTokCommentsController();

  late final StreamingService _streamingService;
  late RtcEngine _engine;
  int? _remoteUid;
  bool _engineReady = false;

  Timer? _heartbeatTimer;
  bool _joined = false;

  String? _channelName;
  String? _agoraToken;
  int _heartbeatInterval = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _streamingService =
        StreamingService(accessToken: widget.accessToken);

    // ONLY join if this is a live stream
    if (widget.feedType == "live") {
      _joinStream();
    }
  }


  Future<void> _initAgora() async {
    _engine = createAgoraRtcEngine();

    await _engine.initialize(
      const RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    await _engine.setClientRole(
      role: ClientRoleType.clientRoleAudience,
    );

    _engine.registerEventHandler(
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

    await _engine.joinChannel(
      token: _agoraToken!,
      channelId: _channelName!,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    setState(() {
      _engineReady = true;
    });
  }


  Future<void> _joinStream() async {
    try {
      final data = await _streamingService.joinLiveStream(
        streamId: widget.streamId,
      );

      if (!mounted) return;

      setState(() {
        _channelName = data["channel_name"];
        _agoraToken = data["agora_token"];
        _heartbeatInterval = data["heartbeat_interval"] ?? 10;
        _joined = true;
      });

      _startHeartbeat();
      await _initAgora(); // move this inside try
    } catch (_) {
      _showErrorAndExit("Failed to join stream");
    }
  }

  /// ❤️ HEARTBEAT
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();

    _heartbeatTimer = Timer.periodic(
      Duration(seconds: _heartbeatInterval),
      (_) async {
        try {
          await _streamingService.sendHeartbeat(
            streamId: widget.streamId,
          );
        } catch (_) {
          _showErrorAndExit("Connection lost");
        }
      },
    );
  }

  /// 🚪 LEAVE STREAM
  Future<void> _leaveStream() async {
    if (!_joined) return;

    _heartbeatTimer?.cancel();

    try {
      await _streamingService.leaveLiveStream(
        streamId: widget.streamId,
      );
    } catch (_) {}
  }

  /// 🛑 HANDLE BACKGROUND / APP CLOSE
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _leaveStream();
    }
  }

  void _showErrorAndExit(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    Navigator.pop(context);
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    commentsController.addComment(text);
    _commentController.clear();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    _leaveStream();
    _commentController.dispose();
    try {
      _engine.leaveChannel();
      _engine.release();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGrace = widget.feedType == "grace";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 🎥 VIDEO PLACEHOLDER (Agora mounts here next step)
          _engineReady && _remoteUid != null
            ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: RtcConnection(channelId: _channelName),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

          /// 👤 TOP INFO
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 15,
            child: Row(
              children: [
                const CircleAvatar(radius: 18),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isGrace ? "Ended" : "Live",
                      style: TextStyle(
                        color: isGrace
                            ? Colors.grey
                            : Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 🎯 ACTIONS (disabled for grace)
          if (!isGrace)
            Positioned(
              right: 10,
              bottom: 160,
              child: Column(
                children: const [
                  LiveAction(icon: Icons.attach_money, label: "Sub"),
                  SizedBox(height: 12),
                  LiveAction(icon: Icons.card_giftcard, label: "Gift"),
                  SizedBox(height: 12),
                  LiveAction(icon: Icons.person_add, label: "Follow"),
                  SizedBox(height: 12),
                  LiveAction(icon: Icons.share, label: "Share"),
                ],
              ),
            ),

          /// 💬 COMMENTS
          TikTokComments(controller: commentsController),

          /// ✍️ COMMENT INPUT (only for live)
          if (!isGrace)
            Positioned(
              bottom: 40,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _sendComment(),
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: const TextStyle(
                            color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white12,
                        contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.white),
                    onPressed: _sendComment,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
