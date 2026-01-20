import 'package:flutter/material.dart';
import '../live/live_streaming_page.dart';
import '../../services/live_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LiveService _liveService = LiveService();
  final PageController _pageController = PageController();

  List<Map<String, dynamic>> _liveStreams = [];

  
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLives();
  }

  Future<void> _loadLives() async {
    try {
      final liveStreams = await _liveService.fetchLiveStreams();
      final recommendedVideos = await _liveService.fetchRecommendedVideos();

      final mergedList = [...liveStreams, ...recommendedVideos]..shuffle();

      setState(() {
        _liveStreams = mergedList;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Failed to load content: $e");
      setState(() => _loading = false);
    }
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _liveStreams.length,
                  itemBuilder: (context, index) {
                    final stream = _liveStreams[index];
                    return _LivePreviewItem(
                      stream: stream,
                      onTap: () => _openLive(context, stream),
                    );
                  },
                ),

                // 🔍 Search Overlay
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 15,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Search / Discover
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:
                          const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _openLive(BuildContext context, Map<String, dynamic> stream) {
    final isLive = stream["is_live"] == true;
    final isEnded = stream["is_ended"] == true;

    if (isLive && isEnded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This live stream has ended")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveStreamingPage(
          streamId: stream["id"].toString(),
          title: stream["title"] ?? "Live",
          isHost: false,
          agoraToken: stream["agora_token"],
          channelName: stream["agora_channel"],
          uid: stream["uid"],
          // For video posts, you can pass video_url and handle playback inside LiveStreamingPage
          videoUrl: stream["video_url"],
          isLive: isLive,
        ),
      ),
    );
  }

}

/// ─────────────────────────────────────────────
/// Live Preview Card (NO AGORA, NO WS)
/// ─────────────────────────────────────────────
class _LivePreviewItem extends StatelessWidget {
  final Map<String, dynamic> stream;
  final VoidCallback onTap;

  const _LivePreviewItem({required this.stream, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLive = stream["is_live"] == true;
    final isEnded = stream["is_ended"] == true;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  stream["thumbnail"] ??
                      "https://via.placeholder.com/600x900",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark overlay
          Container(color: Colors.black26),

          // Bottom info
          Positioned(
            bottom: 80,
            left: 15,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stream["title"] ?? "Video",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (isLive && !isEnded)
                  Text("${stream["viewer_count"] ?? 0} watching",
                      style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // Badge: LIVE / ENDED / VIDEO
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isLive
                    ? (isEnded ? Colors.grey : Colors.redAccent)
                    : Colors.blueAccent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isLive
                    ? (isEnded ? "ENDED" : "LIVE")
                    : "VIDEO",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

