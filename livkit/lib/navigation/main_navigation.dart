import 'package:flutter/material.dart';

import '../pages/home/home_page.dart';
import '../pages/live/live_streaming_page.dart';
import '../pages/live/go_live_page.dart';
import '../pages/chat/chat_page.dart';
import '../pages/profile/self_profile_screen.dart';
import '../pages/settings/demo_page.dart';
import 'bottom_nav.dart';

import '../services/auth_service.dart';
import '../services/chat_service.dart';


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
      // Check paid access first
      final hasPaid = await auth.hasLifetimeAccess();
      if (!hasPaid && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DemoPage()),
        );
        return;
      }

      // Fetch the token correctly
      final token = await auth.getAccessToken() ?? "";
      if (mounted) {
        setState(() {
          _userToken = token;
          _isLoading = false;
        });
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
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GoLivePage()),
      );
      return;
    }

    setState(() => _selectedIndex = index);
  }


  Widget _buildChatPage() {
    // Safe to use _userToken because _pages only builds after loading
    return ChatPageList(
      
      token: _userToken!,
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
      const SizedBox(), // Discover / placeholder (NOT live)
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
