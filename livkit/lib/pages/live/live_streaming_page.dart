import 'package:flutter/material.dart';
import '../../widgets/live_action.dart';
import '../../widgets/tiktok_comments.dart';
import '../profile/profile_screen.dart';


class LiveStreamingPage extends StatefulWidget {
  final String title;

  const LiveStreamingPage({super.key, this.title = "Live Now"});

  @override
  State<LiveStreamingPage> createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();

  /// ✅ PUBLIC CONTROLLER (NO PRIVATE STATE ACCESS)
  final TikTokCommentsController commentsController =
      TikTokCommentsController();

  late final AnimationController _animController;
  late final Animation<double> _fadeScale;

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
  }

  @override
  void dispose() {
    controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void sendComment() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    commentsController.addComment(text);
    controller.clear();
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
              // 🔴 LIVE VIDEO PLACEHOLDER
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/live_bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 👤 TOP USER INFO
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 15,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
                            "2.4K viewers",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

              // 💬 TIKTOK COMMENTS (DEFAULT + USER)
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
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => sendComment(),
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
                    const SizedBox(width: 6),
                    IconButton(
                      icon:
                          const Icon(Icons.send, color: Colors.white),
                      onPressed: sendComment,
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
