import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../widgets/live_action.dart';
import '../../widgets/tiktok_comments.dart';
import '../profile/profile_screen.dart';
import 'live_feed_item.dart';

class LiveStreamingPage extends StatefulWidget {
  final LiveFeedItem feedItem;
  final bool isActive;

  const LiveStreamingPage({
    super.key,
    required this.feedItem,
    required this.isActive,
  });

  @override
  State<LiveStreamingPage> createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final TikTokCommentsController commentsController =
      TikTokCommentsController();

  VideoPlayerController? _videoController;

  late final AnimationController _animController;
  late final Animation<double> _fadeScale;

  bool _joinedAgora = false;

  // =========================
  // LIFECYCLE
  // =========================
  @override
  void initState() {
    super.initState();

    print("🎬 Open LiveStreamingPage");
    print("Type: ${widget.feedItem.type}");
    print("Video URL: ${widget.feedItem.videoUrl}");
    print("Is live: ${widget.feedItem.isLive}");

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeScale = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _animController.forward();

    _initMedia();
    _handleVisibility();
  }

  @override
  void didUpdateWidget(covariant LiveStreamingPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive ||
        oldWidget.feedItem.streamId != widget.feedItem.streamId) {
      print("🔁 Feed visibility/media changed");
      _handleVisibility();
    }
  }

  @override
  void dispose() {
    print("🧹 Dispose LiveStreamingPage");

    _leaveAgora();
    _videoController?.dispose();
    _commentController.dispose();
    _animController.dispose();

    super.dispose();
  }

  // =========================
  // MEDIA INITIALIZATION
  // =========================
  void _initMedia() {
    if (widget.feedItem.type == "fallback" ||
        widget.feedItem.type == "grace") {
      final url = widget.feedItem.videoUrl;

      if (url == null || url.isEmpty) {
        print("⚠️ No video URL provided");
        return;
      }

      print("🎥 Initializing video player: $url");

      _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          setState(() {});
          _videoController?.setLooping(true);
          _videoController?.play();
          print("▶️ Video playback started");
        });
    }
  }

  // =========================
  // AGORA CONTROL (LIVE)
  // =========================
  void _joinAgora() {
    if (_joinedAgora) return;

    print("🟢 JOIN AGORA");
    print("Stream ID: ${widget.feedItem.streamId}");
    print("Channel: ${widget.feedItem.channelName}");

    // TODO: Agora join logic here

    _joinedAgora = true;
  }

  void _leaveAgora() {
    if (!_joinedAgora) return;

    print("🔴 LEAVE AGORA");
    print("Stream ID: ${widget.feedItem.streamId}");

    // TODO: Agora leave logic here

    _joinedAgora = false;
  }

  void _handleVisibility() {
    if (widget.isActive && widget.feedItem.isLive) {
      _joinAgora();
    } else {
      _leaveAgora();
    }

    if (!widget.isActive) {
      _videoController?.pause();
    } else if (widget.feedItem.type == "fallback") {
      _videoController?.play();
    }
  }

  // =========================
  // VIDEO LAYER
  // =========================
  Widget _buildVideoLayer() {
    // LIVE: Agora surface goes here
    if (widget.feedItem.isLive) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            "🔴 LIVE",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    // FALLBACK / GRACE: real video
    if (_videoController != null &&
        _videoController!.value.isInitialized) {
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

    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // =========================
  // COMMENT INPUT
  // =========================
  Widget _buildCommentInput() {
    if (!widget.feedItem.isLive) return const SizedBox.shrink();

    return Positioned(
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
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _sendComment,
          ),
        ],
      ),
    );
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    print("💬 Comment sent: $text");
    commentsController.addComment(text);
    _commentController.clear();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeScale,
        child: Stack(
          children: [
            _buildVideoLayer(),

            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 15,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
                child: Text(
                  widget.feedItem.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (widget.feedItem.isLive)
              Positioned(
                right: 10,
                bottom: 160,
                child: Column(
                  children: const [
                    LiveAction(icon: Icons.card_giftcard, label: "Gift"),
                    SizedBox(height: 12),
                    LiveAction(icon: Icons.share, label: "Share"),
                  ],
                ),
              ),

            if (widget.feedItem.isLive)
              TikTokComments(controller: commentsController),

            _buildCommentInput(),
          ],
        ),
      ),
    );
  }
}
