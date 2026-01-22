import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FriendService {
  final AuthService _auth = AuthService();
  static const String _baseUrl = "https://livkit.onrender.com/api";

  /// ---------------------------
  /// SEARCH USERS
  /// ---------------------------
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final token = await _auth.getAccessToken();
    if (token == null) return [];

    final res = await http.get(
      Uri.parse("$_baseUrl/chat/search/?q=$query"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(data["results"]);
  }

  /// ---------------------------
  /// FRIEND REQUESTS
  /// ---------------------------
  Future<bool> sendFriendRequest(dynamic userId) async {
    final token = await _auth.getAccessToken();
    if (token == null) return false;

    final res = await http.post(
      Uri.parse("$_baseUrl/chat/request/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"user_id": userId.toString()}),
    );

    return res.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final token = await _auth.getAccessToken();
    if (token == null) return [];

    final res = await http.get(
      Uri.parse("$_baseUrl/chat/requests/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(data["pending_requests"]);
  }

  Future<bool> respondToRequest(int requestId, bool accept) async {
    final token = await _auth.getAccessToken();
    if (token == null) return false;

    final res = await http.post(
      Uri.parse("$_baseUrl/chat/requests/respond/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"request_id": requestId, "accept": accept}),
    );

    return res.statusCode == 200;
  }

  /// ---------------------------
  /// FRIEND LIST (STILL VALID)
  /// ---------------------------
  Future<List<Map<String, dynamic>>> getFriends() async {
    final token = await _auth.getAccessToken();
    if (token == null) return [];

    final res = await http.get(
      Uri.parse("$_baseUrl/chat/friend"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(data["friends"]);
  }

  /// ---------------------------
  /// ✅ CONVERSATIONS (NEW – REQUIRED)
  /// ---------------------------
  Future<List<Map<String, dynamic>>> getConversations() async {
    final token = await _auth.getAccessToken();
    if (token == null) return [];

    // ⚠️ FIX: Use correct path registered in Django
    final res = await http.get(
      Uri.parse("$_baseUrl/chat/conversations/"), // <--- was /conversations/
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch conversations");
    }

    final data = jsonDecode(res.body);

    // The serializer returns {"id", "type", "title", "last_message_at", "members", "last_message"}
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> getOrCreateFriendConversation(int friendId) async {
    final token = await _auth.getAccessToken();
    if (token == null) throw Exception("Unauthorized");

    final res = await http.post(
      Uri.parse("$_baseUrl/chat/friend_conversation/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"friend_id": friendId}), // ✅ INT, not String
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to get or create conversation");
    }

    return jsonDecode(res.body);
  }


}
