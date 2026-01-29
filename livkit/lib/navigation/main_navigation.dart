import 'package:flutter/material.dart';

import '../pages/home/home_page.dart';
import '../pages/live/viewer_page.dart';
import '../pages/live/go_live_page.dart';
import '../pages/chat/chat_page.dart';
import '../pages/profile/self_profile_screen.dart';
import '../pages/settings/demo_page.dart';
import 'bottom_nav.dart';

import '../services/auth_service.dart';
import '../services/streaming_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _userToken;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  /// Fetch token and check paid access
  Future<void> _initializeUser() async {
    final auth = AuthService();

    try {
      final hasPaid = await auth.hasLifetimeAccess();
      if (!hasPaid && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DemoPage()),
        );
        return;
      }

      final token = await auth.getAccessToken();
      if (mounted && token != null && token.isNotEmpty) {
        setState(() {
          _userToken = token;
          _isLoading = false;
        });
      } else {
        throw Exception("No auth token");
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DemoPage()),
        );
      }
    }
  }

  void _onTabTap(int index) {
    // 🎥 GO LIVE (special case)
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GoLivePage(
            accessToken: _userToken!,
          ),
        ),
      );
      return;
    }

    setState(() => _selectedIndex = index);
  }

  Widget _buildChatPage() {
    return ChatPageList(
      token: _userToken!,
    );
  }

  /// Live Discovery / Viewer launcher
  Widget _buildLivePage() {
    return FutureBuilder<Map<String, dynamic>>(
      future: StreamingService(accessToken: _userToken!).fetchActiveStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Text(
              "No live streams currently",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final stream = snapshot.data!;
        // Tap to enter ViewerPage
        return Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewerPage(
                    streamId: stream["id"],
                    channelName: stream["channel_name"],
                    agoraToken: stream["agora_token"],
                    accessToken: _userToken!,
                    title: stream["title"] ?? "Live Now",
                  ),
                ),
              );
            },
            child: const Text("Watch Live Stream"),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _userToken == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> _pages = [
      const HomePage(),
      _buildLivePage(), // Viewer discovery
      const SizedBox(), // Go Live handled manually
      _buildChatPage(),
      const SelfProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNav(
        onTap: _onTabTap,
        selected: _selectedIndex,
      ),
    );
  }
}
