import 'package:flutter/material.dart';
import '../live/live_streaming_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🔥 Vertical TikTok-style Live Feed
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _AnimatedLiveItem(
                index: index,
                child: const LiveStreamingPage(),
              );
            },
          ),

          // 🔍 Search Button (Overlay)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 15,
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to Search Page
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================
/// Animated Live Item
/// =====================
class _AnimatedLiveItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedLiveItem({
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: child,
          ),
        );
      },
    );
  }
}
