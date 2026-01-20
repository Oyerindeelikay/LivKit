import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final PageController _pageController = PageController();
  final int _numPages = 5;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _numPages;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AnimatedLoginPage()),
      (_) => false,
    );
  }

  void _showPaidOnlyDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: const Text("Access Restricted"),
        content: const Text(
          "LivKit is for premium users only.\n\nPlease complete payment to unlock full access.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel({
    required Color color,
    required String title,
    required String subtitle,
    Widget? child,
  }) {
    return Container(
      color: color,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (child != null) child,
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _liveStreamCard(String streamer, String viewers) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      width: 200,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue,
            child: Text(
              streamer[0],
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            streamer,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$viewers viewers',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              _buildPanel(
                color: const Color(0xFF1E1E1E),
                title: "Live Streams",
                subtitle: "Watch live streams from creators worldwide",
                child: SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _liveStreamCard("Alice", "120"),
                      _liveStreamCard("Bob", "85"),
                      _liveStreamCard("Charlie", "200"),
                      _liveStreamCard("Diana", "150"),
                    ],
                  ),
                ),
              ),
              _buildPanel(
                color: const Color(0xFF1B1B2F),
                title: "Earn Rewards",
                subtitle: "Get coins while watching streams",
                child: const Icon(Icons.monetization_on, size: 100, color: Colors.amber),
              ),
              _buildPanel(
                color: const Color(0xFF2C1B2F),
                title: "Interact",
                subtitle: "Chat and connect with streamers",
                child: const Icon(Icons.chat_bubble, size: 100, color: Colors.purpleAccent),
              ),
              _buildPanel(
                color: const Color(0xFF1E2C3F),
                title: "Premium Access",
                subtitle: "One-time payment. Lifetime access.",
                child: const Icon(Icons.star, size: 100, color: Colors.yellowAccent),
              ),
              _buildPanel(
                color: const Color(0xFF2F3F4F),
                title: "Join Now",
                subtitle: "Upgrade to unlock LivKit",
                child: ElevatedButton(
                  onPressed: _showPaidOnlyDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Get Started", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 28),
              onPressed: _logout,
            ),
          ),
        ],
      ),
    );
  }
}
