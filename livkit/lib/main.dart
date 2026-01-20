import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

import 'navigation/auth_gate.dart';
import 'navigation/app_navigator.dart';
import 'pages/auth/reset_password_page.dart';

void main() {
  runApp(const LivkitApp());
}

class LivkitApp extends StatefulWidget {
  const LivkitApp({super.key});

  @override
  State<LivkitApp> createState() => _LivkitAppState();
}

class _LivkitAppState extends State<LivkitApp> {
  StreamSubscription? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      // 🔹 Cold start (app closed)
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleUri(initialUri);
      }

      // 🔹 App already running
      _linkSub = uriLinkStream.listen((uri) {
        if (uri != null) {
          _handleUri(uri);
        }
      });
    } catch (_) {
      // Silently fail (safe)
    }
  }

  void _handleUri(Uri uri) {
    if (uri.path == '/reset-password') {
      final uid = uri.queryParameters['uid'];
      final token = uri.queryParameters['token'];

      if (uid != null && token != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(
              uid: uid,
              token: token,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
