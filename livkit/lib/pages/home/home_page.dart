import 'package:flutter/material.dart';

import '../../services/streaming_service.dart';
import '../../models/feed_item.dart';
import '../live/viewer_page.dart';
import '../video/fallback_video_page.dart';

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

    for (final stream in data["feed"]) {
      items.add(FeedItem.fromStream(stream));
    }

    for (final video in data["fallbacks"]) {
      items.add(FeedItem.fromFallback(video));
    }

    items.shuffle(); // 🔀 viewer-specific randomness
    return items;
  }

  Future<void> _refresh() async {
    setState(() {
      _feedFuture = _loadFeed();
    });
  }

  void _onItemTap(FeedItem item) {
    if (item.type == "live" || item.type == "grace") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewerPage(
            streamId: item.streamId!,
            accessToken: widget.accessToken,
            title: item.streamer ?? "Stream",
            feedType: item.type, // 🔥 IMPORTANT
          ),
        ),
      );
    }else if (item.type == "fallback") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FallbackVideoPage(
            title: item.channelName ?? "Video",
            videoUrl: item.videoUrl!,
          ),
        ),
      );
    }
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
        Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: Text(
            item.channelName ?? "Video",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        if (item.type == "live")
          const Positioned(
            top: 60,
            left: 20,
            child: _LiveBadge(),
          ),

        if (item.type == "grace")
          const Positioned(
            top: 60,
            left: 20,
            child: _GraceBadge(),
          ),
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

  const _Badge({required this.label, required this.color});

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
