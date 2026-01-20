import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../pages/auth/login_page.dart';
import '../pages/settings/demo_page.dart';
import '../navigation/main_navigation.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    try {
      final token = await _authService.getAccessToken();

      // No token or expired → go login
      if (token == null || Jwt.isExpired(token)) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AnimatedLoginPage()),
        );
        return;
      }

      // Check if banned
      if (await _authService.isBanned()) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AnimatedLoginPage()),
        );
        return;
      }

      // Paid users → MainNavigation
      final hasPaid = await _authService.hasLifetimeAccess();

      if (!mounted) return;

      if (hasPaid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else {
        // Unpaid users → DemoPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DemoPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AnimatedLoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
