import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FeedVideo extends StatefulWidget {
  final String type;
  final String? videoUrl;

  const FeedVideo({
    super.key,
    required this.type,
    this.videoUrl,
  });

  @override
  State<FeedVideo> createState() => _FeedVideoState();
}

class _FeedVideoState extends State<FeedVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();

    if (widget.type == "fallback" && widget.videoUrl != null) {
      _controller = VideoPlayerController.network(widget.videoUrl!)
        ..initialize().then((_) {
          if (!mounted) return;
          _controller!.setLooping(true);
          _controller!.play();
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // LIVE / GRACE placeholder
    if (widget.type != "fallback") {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Text(
          widget.type == "live" ? "LIVE STREAM" : "STREAM ENDED",
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    // Fallback loading
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // 🔒 HARD CONSTRAINTS (THIS FIXES THE CRASH)
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
}