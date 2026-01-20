import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminAuthService {
  static const _storage = FlutterSecureStorage();

  static const _accessKey = "admin_access";
  static const _refreshKey = "admin_refresh";
  static const _roleKey = "admin_role";

  static const baseUrl = "http://127.0.0.1:8000/api";

  String? _role;

  // ---------------- LOGIN ----------------
  Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/admin/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Invalid admin credentials");
    }

    final data = jsonDecode(res.body);

    await _storage.write(key: _accessKey, value: data["access"]);
    await _storage.write(key: _refreshKey, value: data["refresh"]);
    await _storage.write(key: _roleKey, value: data["role"]);

    _role = data["role"];
  }

  // ---------------- LOAD SESSION ----------------
  Future<void> loadUserFromToken() async {
    _role = await _storage.read(key: _roleKey);
  }

  // ---------------- GETTERS ----------------
  Future<String?> getToken() async =>
      await _storage.read(key: _accessKey);

  bool get isAdmin =>
      _role == 'ADMIN_MAIN' || _role == 'ADMIN_LIMITED';

  bool get isMainAdmin => _role == 'ADMIN_MAIN';

  bool get isLimitedAdmin => _role == 'ADMIN_LIMITED';

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    final token = await getToken();

    if (token != null) {
      await http.post(
        Uri.parse("$baseUrl/auth/admin/logout/"),
        headers: {"Authorization": "Bearer $token"},
      );
    }

    await _storage.deleteAll();
    _role = null;
  }
}
