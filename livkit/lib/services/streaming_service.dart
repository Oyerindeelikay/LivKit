import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class StreamingService {
  final String baseUrl;

  final Future<String?> Function() getAuthToken;

  StreamingService({
    
    required this.baseUrl,
    required this.getAuthToken,
  });

  // ========================
  // Internal helpers
  // ========================

  Future<Map<String, String>> _headers() async {
    final token = await getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('🎥 [StreamingService] $message');
    }
  }

  // ========================
  // Schedule Live
  // ========================

  Future<Map<String, dynamic>> scheduleLive({
    required int roomId,
    required DateTime scheduledStart,
  }) async {
    _log('Scheduling live…');

    final response = await http.post(
      Uri.parse('$baseUrl/schedule/'),
      headers: await _headers(),
      body: jsonEncode({
        'room_id': roomId,
        'scheduled_start': scheduledStart.toIso8601String(),
      }),
    );

    _log('Schedule response: ${response.statusCode}');
    _log(response.body);

    if (response.statusCode != 201) {
      throw Exception('Failed to schedule live');
    }

    return jsonDecode(response.body);
  }

  // ========================
  // Go Live (Host)
  // ========================

  Future<HmsJoinData> goLive({
    required int sessionId,
  }) async {
    _log('Requesting host token…');

    final response = await http.post(
      Uri.parse('$baseUrl/golive/'),
      headers: await _headers(),
      body: jsonEncode({
        'session_id': sessionId,
      }),
    );

    _log('GoLive response: ${response.statusCode}');
    _log(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to go live');
    }

    final data = jsonDecode(response.body);

    return HmsJoinData(
      token: data['token'],
      roomId: data['room_id'],
      sessionId: data['session_id'],
    );
  }

  // ========================
  // Viewer Join Live
  // ========================

  Future<HmsJoinData> joinLiveAsViewer({
    required int sessionId,
  }) async {
    _log('Viewer joining live…');

    final response = await http.post(
      Uri.parse('$baseUrl/viewer/join/'),
      headers: await _headers(),
      body: jsonEncode({
        'session_id': sessionId,
      }),
    );

    _log('Viewer join response: ${response.statusCode}');
    _log(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to join live');
    }

    final data = jsonDecode(response.body);

    return HmsJoinData(
      token: data['token'],
      roomId: data['room_id'],
      sessionId: data['session_id'],
    );
  }

  // ========================
  // End Live (Host)
  // ========================

  Future<Map<String, dynamic>> endLive({
    required int sessionId,
  }) async {
    _log('Ending live…');

    final response = await http.post(
      Uri.parse('$baseUrl/end/'),
      headers: await _headers(),
      body: jsonEncode({
        'session_id': sessionId,
      }),
    );

    _log('EndLive response: ${response.statusCode}');
    _log(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to end live');
    }

    return jsonDecode(response.body);
  }
}

// ========================
// Models
// ========================

class HmsJoinData {
  final String token;
  final String roomId;
  final int sessionId;

  HmsJoinData({
    required this.token,
    required this.roomId,
    required this.sessionId,
  });
}
