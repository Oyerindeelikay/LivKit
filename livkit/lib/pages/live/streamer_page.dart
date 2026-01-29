import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../widgets/live_action.dart';
import '../../widgets/tiktok_comments.dart';
import '../../services/streaming_service.dart';
import 'package:permission_handler/permission_handler.dart';

class StreamerPage extends StatefulWidget {
  final String streamId;
  final String channelName;
  final String agoraToken;
  final String accessToken;
  final String title;

  const StreamerPage({
    super.key,
    required this.streamId,
    required this.channelName,
    required this.agoraToken,
    required this.accessToken,
    this.title = "Live Now",
  });

  @override
  State<StreamerPage> createState() => _StreamerPageState();
}

class _StreamerPageState extends State<StreamerPage>
    with SingleTickerProviderStateMixin {
  late final RtcEngine _engine;
  bool _isLive = false;

  final TextEditingController _commentController = TextEditingController();
  final TikTokCommentsController commentsController =
      TikTokCommentsController();

  late final AnimationController _animController;
  late final Animation<double> _fadeScale;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initAgora();
  }


  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fadeScale =
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);

    _animController.forward();
  }
  
  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  Future<void> _initAgora() async {
    _engine = createAgoraRtcEngine();

    await _engine.initialize(
      const RtcEngineContext(
        appId: String.fromEnvironment('AGORA_APP_ID'),
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
    );

    await _engine.joinChannel(
      token: widget.agoraToken,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    setState(() => _isLive = true);
  }

  bool _isEnding = false;

  Future<void> _endLive() async {
    if (_isEnding) return; // Prevent double-tap
    _isEnding = true;

    final streamingService = StreamingService(accessToken: widget.accessToken);

    try {
      await streamingService.endLiveStream(streamId: widget.streamId);

      // Leave Agora channel
      try {
        await _engine.leaveChannel();
        await _engine.release();
      } catch (e) {
        debugPrint("Agora leave/release error: $e");
      }

      // Show success message (optional)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Live stream ended")),
        );

        // Go back to homepage
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("End live error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to end stream: $e")),
        );
      }
    } finally {
      _isEnding = false;
    }
  }



  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    commentsController.addComment(text);
    _commentController.clear();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _animController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeScale,
        child: ScaleTransition(
          scale: Tween(begin: 0.97, end: 1.0).animate(_fadeScale),
          child: Stack(
            children: [
              // 🎥 LIVE VIDEO
              AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),

              // 🔝 TOP INFO
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 15,
                right: 15,
                child: Row(
                  children: [
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
                        const Text(
                          "LIVE",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _endLive,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "END",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🎯 RIGHT ACTIONS
              Positioned(
                right: 10,
                bottom: 160,
                child: Column(
                  children: const [
                    LiveAction(icon: Icons.attach_money, label: "Sub"),
                    SizedBox(height: 12),
                    LiveAction(icon: Icons.card_giftcard, label: "Gift"),
                    SizedBox(height: 12),
                    LiveAction(icon: Icons.person_add, label: "Join"),
                    SizedBox(height: 12),
                    LiveAction(icon: Icons.share, label: "Share"),
                  ],
                ),
              ),

              // 💬 COMMENTS
              TikTokComments(controller: commentsController),

              // ✍️ COMMENT INPUT
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
                          hintStyle:
                              const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white12,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendComment,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
