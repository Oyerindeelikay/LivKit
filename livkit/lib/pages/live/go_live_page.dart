import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../../services/streaming_service.dart';
import '../../widgets/live_action.dart';
import '../../widgets/tiktok_comments.dart';
import '../profile/profile_screen.dart';

class StreamerPage extends StatefulWidget {
  final int sessionId;
  final String title;
  final StreamingService streamingService;

  const StreamerPage({
    super.key,
    required this.sessionId,
    required this.streamingService,
    this.title = 'Live Now',
  });

  @override
  State<StreamerPage> createState() => _StreamerPageState();
}


class _StreamerPageState extends State<StreamerPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final TextEditingController commentController = TextEditingController();
  final TikTokCommentsController commentsController =
      TikTokCommentsController();

  late final HMSSDK _hmsSdk;

  bool _joinedRoom = false;
  bool _endingLive = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeScale;

  void _log(String msg) {
    if (kDebugMode) {
      debugPrint('🔴 [StreamerPage] $msg');
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _hmsSdk = HMSSDK();
    _startLiveFlow();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fadeScale =
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);

    _animController.forward();
  }

  // =========================
  // LIVE FLOW
  // =========================

  Future<void> _startLiveFlow() async {
    _log('Starting live flow for session ${widget.sessionId}');

    try {
      final joinData = await widget.streamingService.goLive(
        sessionId: widget.sessionId,
      );

      _log('Received HMS token, joining room');

      await _hmsSdk.join(
        config: HMSConfig(
          authToken: joinData.token,
          userName: 'host-${widget.sessionId}',
        ),
      );



      _joinedRoom = true;
      _log('Successfully joined HMS room');
    } catch (e, stack) {
      _log('FAILED to start live: $e');
      _log(stack.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to go live')),
        );
        Navigator.pop(context);
      }
    }
  }

  // =========================
  // END LIVE (SAFE)
  // =========================

  Future<void> _endLive() async {
    if (_endingLive) return;
    _endingLive = true;

    _log('Ending live session');

    try {
      if (_joinedRoom) {
        await _hmsSdk.leave();
        _log('Left HMS room');
      }

      await widget.streamingService.endLive(
        sessionId: widget.sessionId,
      );

      _log('Backend live ended successfully');
    } catch (e, stack) {
      _log('ERROR ending live: $e');
      _log(stack.toString());
    }
  }

  // =========================
  // LIFECYCLE HANDLING
  // =========================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _log('App lifecycle exit detected');
      _endLive();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    commentController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // =========================
  // COMMENTS
  // =========================

  void _sendComment() {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    commentsController.addComment(text);
    commentController.clear();
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
        child: ScaleTransition(
          scale: Tween(begin: 0.97, end: 1.0).animate(_fadeScale),
          child: Stack(
            children: [
              // 🎥 VIDEO SURFACE PLACEHOLDER
              Container(
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'LIVE VIDEO STREAM',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),

              // 👤 TOP INFO
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
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 🎯 ACTIONS
              Positioned(
                right: 10,
                bottom: 160,
                child: Column(
                  children: const [
                    LiveAction(icon: Icons.attach_money, label: 'Sub'),
                    SizedBox(height: 12),
                    LiveAction(icon: Icons.card_giftcard, label: 'Gift'),
                    SizedBox(height: 12),
                    LiveAction(icon: Icons.person_add, label: 'Join'),
                    SizedBox(height: 12),
                    LiveAction(icon: Icons.share, label: 'Share'),
                  ],
                ),
              ),

              // 💬 COMMENTS
              TikTokComments(controller: commentsController),

              // ✍️ INPUT
              Positioned(
                bottom: 40,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => _sendComment(),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle:
                              const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white12,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
