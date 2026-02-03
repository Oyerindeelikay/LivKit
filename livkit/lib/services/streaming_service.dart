import 'dart:convert';
import 'package:http/http.dart' as http;

class StreamingService {
  static const String baseUrl = "https://livkit.onrender.com/api/streaming";

  final String accessToken;

  StreamingService({required this.accessToken});

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      };

  /// CREATE LIVE (Streamer)
  Future<Map<String, dynamic>> createLiveStream({
    required String title,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create/"),
      headers: _headers,
      body: jsonEncode({"title": title}),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create live stream");
    }

    return jsonDecode(response.body);
  }

  /// JOIN LIVE (Viewer)
  Future<Map<String, dynamic>> joinLiveStream({
    required String streamId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$streamId/join/"),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to join live stream");
    }

    return jsonDecode(response.body);
  }

  /// HEARTBEAT (Viewer)
  Future<void> sendHeartbeat({
    required String streamId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$streamId/heartbeat/"),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Heartbeat failed");
    }
  }

  /// LEAVE LIVE (Viewer)
  Future<void> leaveLiveStream({
    required String streamId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$streamId/leave/"),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to leave live stream");
    }
  }

  /// END LIVE (Streamer)
  Future<void> endLiveStream({
    required String streamId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$streamId/end/"),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to end live stream");
    }
  }

  /// Fetch one currently active live stream
  Future<Map<String, dynamic>> fetchActiveStream() async {
    final url = Uri.parse("$baseUrl/active/");
    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch active stream");
    }

    final data = jsonDecode(response.body);
    if (data.isEmpty) {
      throw Exception("No active stream");
    }

    return data[0];
  }




  /// HOME FEED (Live + Grace + Fallback)
  Future<Map<String, dynamic>> fetchHomeFeed() async {
    final response = await http.get(
      Uri.parse("$baseUrl/feed/"),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load home feed");
    }

    return jsonDecode(response.body);
  }



}
