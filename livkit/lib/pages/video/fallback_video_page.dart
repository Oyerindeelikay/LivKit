import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FallbackVideoPage extends StatefulWidget {
  final String title;
  final String videoUrl;

  const FallbackVideoPage({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<FallbackVideoPage> createState() =>
      _FallbackVideoPageState();
}

class _FallbackVideoPageState extends State<FallbackVideoPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.network(widget.videoUrl)
          ..initialize().then((_) {
            setState(() {});
            _controller.play();
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
