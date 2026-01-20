import 'dart:convert';
import 'package:http/http.dart' as http;

class EarningService {
  static const _baseUrl = "http://127.0.0.1:8000/api";

  Future<Map<String, dynamic>> getStreamEarnings({
    required String token,
    required String streamId,
  }) async {
    final res = await http.get(
      Uri.parse("$_baseUrl/streams/$streamId/earnings/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch earnings");
    }

    return jsonDecode(res.body);
  }
}
