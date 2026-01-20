import 'package:flutter/material.dart';
import '../../services/agora_service.dart';
import '../../services/live_service.dart';
import '../../services/minutes_service.dart';
import '../../services/live_room_ws_service.dart';
import '../../widgets/live_action.dart';
import '../../widgets/tiktok_comments.dart';
import '../profile/profile_screen.dart';
import 'package:video_player/video_player.dart';


class LiveStreamingPage extends StatefulWidget {
  final String streamId;
  final String title;
  final bool isHost;
  final String? agoraToken;
  final String? channelName;
  final int? uid;
  final String? videoUrl;
  final bool isLive;

  const LiveStreamingPage({
    super.key,
    required this.streamId,
    required this.title,
    this.isHost = false,
    this.agoraToken,
    this.channelName,
    this.uid,
    this.videoUrl,
    this.isLive = true,
  });

  @override
  State<LiveStreamingPage> createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage>
    with SingleTickerProviderStateMixin {
  final AgoraService _agora = AgoraService();
  final LiveService _liveService = LiveService();
  final MinutesService _minutesService = MinutesService();
  final LiveRoomWsService _wsService = LiveRoomWsService();

  final TikTokCommentsController _commentsController =
      TikTokCommentsController();
  final TextEditingController _commentInput = TextEditingController();


  late final AnimationController _animController;
  late final Animation<double> _fadeScale;

  int _viewerCount = 0;
  bool _joining = true;

  // Video controller for fallback video posts
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fadeScale =
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);

    _animController.forward();

    if (widget.isLive) {
      _initLiveRoom();
    } else if (widget.videoUrl != null) {
      _initVideoPost(widget.videoUrl!);
    }
  }

  void _initVideo(String url) {
    _videoController = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {}); // Refresh UI after initialization
        _videoController!.play();
        _videoController!.setLooping(true);
      });
  }


  /// ──────────────── VIDEO POST INIT ────────────────
  Future<void> _initVideoPost(String url) async {
    _videoController = VideoPlayerController.network(url);
    await _videoController!.initialize();
    await _videoController!.setLooping(true);
    await _videoController!.play();

    setState(() => _joining = false);
  }

  /// ──────────────── LIVE STREAM INIT ────────────────
  Future<void> _initLiveRoom() async {
    try {
      if (!widget.isHost) {
        final hasMinutes = await _minutesService.hasEnoughMinutes();
        if (!hasMinutes) {
          _showExit("Not enough minutes to watch");
          return;
        }
      }

      Map<String, dynamic>? joinData;
      if (!widget.isHost) {
        joinData =
            await _liveService.joinLiveStream(int.parse(widget.streamId));
      }

      final agoraToken = widget.isHost
          ? widget.agoraToken
          : joinData?["agora_token"];

      final channelName = widget.isHost
          ? widget.channelName
          : joinData?["agora_channel"];

      final uid = widget.isHost
          ? widget.uid ?? 0
          : joinData?["uid"] ?? 0;

      await _agora.initialize(appId: "YOUR_AGORA_APP_ID");

      await _agora.joinChannel(
        token: agoraToken ?? "",
        channelName: channelName ?? widget.streamId,
        uid: uid,
        isHost: widget.isHost,
      );

      _wsService.connect(
        streamId: widget.streamId,
        accessToken: joinData?["access_token"] ?? "",
        onViewerCount: (count) => setState(() => _viewerCount = count),
        onComment: (user, msg) =>
            _commentsController.addComment("$user: $msg"),
        onMinutesExhausted: () => _showExit("Minutes exhausted"),
        onGenericEvent: _handleGenericEvent,
      );

      setState(() => _joining = false);
    } catch (e) {
      debugPrint("Live init error: $e");
      _showExit("Failed to join live");
    }
  }

  void _handleGenericEvent(Map<String, dynamic> data) {
    if (data["type"] == "stream_ended") {
      _showExit("Live has ended");
    }
  }

  void _sendComment() {
    final text = _commentInput.text.trim();
    if (text.isEmpty) return;

    _wsService.sendComment(
      streamId: widget.streamId,
      message: text,
    );

    _commentInput.clear();
  }

  Future<void> _showExit(String reason) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Live ended"),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );

    if (widget.isLive) {
      await _agora.leaveChannel();
      await _agora.destroy();
      _wsService.disconnect();
    } else {
      await _videoController?.pause();
      await _videoController?.dispose();
    }
  }

  @override
  void dispose() {
    _commentInput.dispose();
    _animController.dispose();
    _videoController?.dispose();

    if (widget.isLive) {
      _agora.destroy();
      _wsService.disconnect();
    } else {
      _videoController?.dispose();
    }
    super.dispose();
  }


  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
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
              _videoLayer(),
              _topInfo(),
              _rightActions(),
              TikTokComments(controller: _commentsController),
              _commentInputBar(),
              if (_joining) _loadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// ─────────── VIDEO OR LIVE FEED ───────────
  Widget _videoLayer() {
    if (widget.isLive) {
      // For live streams, show black background; Agora renders video separately
      return Container(
        color: Colors.black,
      );
    }

    // For video posts
    if (_videoController != null && _videoController!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }

    // Fallback background
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/live_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// ─────────── TOP INFO ───────────
  Widget _topInfo() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 15,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(
                  widget.isLive
                      ? "$_viewerCount viewers"
                      : "Video post",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ─────────── RIGHT ACTIONS ───────────
  Widget _rightActions() {
    // Only show these actions for live streams
    if (!widget.isLive) return const SizedBox.shrink();

    return Positioned(
      right: 10,
      bottom: 160,
      child: Column(
        children: const [
          LiveAction(icon: Icons.card_giftcard, label: "Gift"),
          SizedBox(height: 12),
          LiveAction(icon: Icons.share, label: "Share"),
        ],
      ),
    );
  }

  /// ─────────── COMMENT INPUT BAR ───────────
  Widget _commentInputBar() {
    return Positioned(
      bottom: 40,
      left: 10,
      right: 10,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentInput,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _sendComment(),
              decoration: InputDecoration(
                hintText: widget.isLive
                    ? "Add a comment..."
                    : "Comments disabled for videos",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              enabled: widget.isLive,
            ),
          ),
          if (widget.isLive)
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendComment,
            ),
        ],
      ),
    );
  }

  /// ─────────── LOADING OVERLAY ───────────
  Widget _loadingOverlay() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }
}