// lib/services/live_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';



class LiveService {
  static const String _baseUrl = "https://livkit.onrender.com/api";
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  /// -----------------------------
  /// CREATE / SCHEDULE LIVESTREAM
  /// -----------------------------
  Future<Map<String, dynamic>> createLiveStream({
    required String title,
    String? scheduledAt, // ISO string
  }) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/live/streams/create/"),
      headers: await _headers(),
      body: jsonEncode({
        "title": title,
        if (scheduledAt != null) "scheduled_at": scheduledAt,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception("Failed to create livestream");
    }

    return jsonDecode(res.body);
  }

  /// -----------------------------
  /// START STREAM (HOST)
  Future<Map<String, dynamic>> startLiveStream(String streamId) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/live/streams/$streamId/start/"),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to start livestream");
    }

    return jsonDecode(res.body);
  }

  /// -----------------------------
  /// JOIN STREAM (VIEWER)
  /// Deducts minutes server-side
  /// -----------------------------
  Future<Map<String, dynamic>> joinLiveStream(int streamId) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/live/streams/$streamId/join/"),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception("Unable to join livestream");
    }

    return jsonDecode(res.body);
  }

  /// -----------------------------
  /// END STREAM (HOST)
  /// -----------------------------
  Future<void> endLiveStream(int streamId) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/live/streams/$streamId/end/"),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to end livestream");
    }
  }

  /// -----------------------------
  /// FETCH ACTIVE STREAMS
  /// -----------------------------
  /// 
  


  Future<List<Map<String, dynamic>>> fetchLiveStreams() async {
    final res = await http.get(
      Uri.parse("$_baseUrl/live/streams/"),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load live streams: ${res.body}");
    }

    final decoded = jsonDecode(res.body);

    if (decoded is! List) {
      throw Exception(
        "API returned unexpected format: ${decoded.runtimeType}"
      );
    }

    return decoded
        .map<Map<String, dynamic>>(
          (e) => Map<String, dynamic>.from(e),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchRecommendedVideos() async {
    // Replace with your API call to fetch recommended videos
    // Example dummy data:
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        "id": "vid001",
        "title": "Sample Video 1",
        "thumbnail": "https://via.placeholder.com/600x900",
        "video_url": "https://m.youtube.com/shorts/Y0k1qDdtoUU",
        "is_live": false,
      },
      {
        "id": "vid002",
        "title": "Sample Video 2",
        "thumbnail": "https://via.placeholder.com/600x900",
        "video_url": "https://m.youtube.com/shorts/J47KlLaBrVo",
        "is_live": false,
      },
    ];
  }

  
}
