import 'package:flutter/material.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../config/agora_config.dart';

import '../../services/streaming_service.dart';
import '../../models/feed_item.dart';
import '../live/viewer_page.dart';
import '../live/feed_video.dart';

class HomePage extends StatefulWidget {
  final String accessToken;

  const HomePage({
    super.key,
    required this.accessToken,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamingService _streamingService;
  late Future<List<FeedItem>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _streamingService =
        StreamingService(accessToken: widget.accessToken);
    _feedFuture = _loadFeed();
  }

  Future<List<FeedItem>> _loadFeed() async {
    final data = await _streamingService.fetchHomeFeed();

    final List<FeedItem> items = [];

    if (data["feed"] != null) {
      for (final stream in data["feed"]) {
        items.add(FeedItem.fromStream(stream));
      }
    }

    if (data["fallbacks"] != null) {
      for (final video in data["fallbacks"]) {
        items.add(FeedItem.fromFallback(video));
      }
    }

    return items;
  }

  Future<void> _refresh() async {
    setState(() {
      _feedFuture = _loadFeed();
    });
  }

  void _onItemTap(FeedItem item) {
    // Navigate ONLY for live or grace streams
    if (item.type == "live" || item.type == "grace") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewerPage(
            streamId: item.streamId!,
            accessToken: widget.accessToken,
            title: item.streamer ?? "Live Stream",
            feedType: item.type,
          ),
        ),
      );
    }

    // ❌ NO navigation for fallback videos
    // They autoplay inline like TikTok
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<FeedItem>>(
          future: _feedFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No content available",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final feed = snapshot.data!;

            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: feed.length,
              itemBuilder: (context, index) {
                final item = feed[index];

                return GestureDetector(
                  onTap: () => _onItemTap(item),
                  child: _FeedTile(item: item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// =======================
/// FEED TILE
/// =======================
class _FeedTile extends StatelessWidget {
  final FeedItem item;

  const _FeedTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 🎥 VIDEO CONTENT
        Positioned.fill(
          child: FeedVideo(
            type: item.type,
            videoUrl: item.videoUrl,
            channelName: item.channelName,   // needed for live preview
            agoraToken: item.agoraToken,    // needed for live preview
          ),
        ),

        /// 👤 TOP OVERLAY
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 15,
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                item.streamer ?? "Streamer",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        /// 🔴 BADGES
        if (item.type == "live")
          const Positioned(top: 60, left: 20, child: _LiveBadge()),

        if (item.type == "grace")
          const Positioned(top: 60, left: 20, child: _GraceBadge()),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return _Badge(label: "LIVE", color: Colors.red);
  }
}

class _GraceBadge extends StatelessWidget {
  const _GraceBadge();

  @override
  Widget build(BuildContext context) {
    return _Badge(label: "ENDED", color: Colors.orange);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
