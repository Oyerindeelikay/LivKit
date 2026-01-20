// lib/services/minutes_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MinutesService {
  static const String _baseUrl = "http://127.0.0.1:8000/api";
  final AuthService _auth = AuthService();

  /// Fetch remaining seconds balance
  Future<int> getRemainingSeconds() async {
    final token = await _auth.getAccessToken();
    if (token == null) {
      throw Exception("Not authenticated");
    }

    final res = await http.get(
      Uri.parse("$_baseUrl/payments/minutes/balance/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch minutes balance");
    }

    final data = jsonDecode(res.body);
    return data["seconds_balance"] ?? 0;
  }

  /// Convenience check before joining a stream
  Future<bool> hasEnoughMinutes({int minimumSeconds = 60}) async {
    final seconds = await getRemainingSeconds();
    return seconds >= minimumSeconds;
  }
}
