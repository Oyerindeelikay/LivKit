import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

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
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      // 🔹 Cold start (app closed)
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }

      // 🔹 App already running / backgrounded
      _linkSub = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          _handleUri(uri);
        },
        onError: (_) {
          // Ignore malformed links safely
        },
      );
    } catch (_) {
      // Fail silently – deep links should never crash the app
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
