import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class Session {
  final bool isAuthenticated;
  final bool isPaid;

  Session({required this.isAuthenticated, required this.isPaid});
}

class AuthService {
  static const String _baseUrl = "http://127.0.0.1:8000/api";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// -----------------------------
  /// SIGNUP
  /// -----------------------------
  Future<void> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/auth/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception(jsonDecode(res.body).toString());
    }
  }

  /// -----------------------------
  /// LOGIN
  /// -----------------------------
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/auth/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)["error"] ?? "Login failed");
    }

    final data = jsonDecode(res.body);
    await _storage.write(key: "access", value: data["access"]);
    await _storage.write(key: "refresh", value: data["refresh"]);
  }

  /// -----------------------------
  /// TOKEN HELPERS
  /// -----------------------------
  Future<String?> getAccessToken() => _storage.read(key: "access");
  Future<String?> getRefreshToken() => _storage.read(key: "refresh");
  Future<void> logout() async => await _storage.deleteAll();

  /// -----------------------------
  /// JWT CLAIM HELPERS
  /// -----------------------------
  Future<bool> hasLifetimeAccess() async {
    final access = await getAccessToken();
    if (access == null) return false;

    final res = await http.get(
      Uri.parse("$_baseUrl/auth/me/"),
      headers: {
        "Authorization": "Bearer $access",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode != 200) return false;

    final data = jsonDecode(res.body);
    return data["has_lifetime_access"] == true;
  }


  Future<bool> isBanned() async {
    final token = await getAccessToken();
    if (token == null) return false;

    final claims = Jwt.parseJwt(token);
    return claims["is_banned"] == true;
  }

  /// -----------------------------
  /// REFRESH ACCESS TOKEN
  /// -----------------------------
  Future<void> refreshIfNeeded() async {
    final access = await getAccessToken();
    if (access == null) throw Exception("Not authenticated");

    if (!Jwt.isExpired(access)) return;

    final refresh = await getRefreshToken();
    if (refresh == null) throw Exception("Session expired");

    final res = await http.post(
      Uri.parse("$_baseUrl/auth/refresh/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refresh}),
    );

    if (res.statusCode != 200) {
      await logout();
      throw Exception("Session expired");
    }

    final data = jsonDecode(res.body);
    await _storage.write(key: "access", value: data["access"]);
  }

  /// -----------------------------
  /// FETCH SESSION FROM BACKEND
  /// -----------------------------
  Future<Session> fetchSession() async {
    await refreshIfNeeded();

    final access = await getAccessToken();
    if (access == null) return Session(isAuthenticated: false, isPaid: false);

    final res = await http.get(
      Uri.parse("$_baseUrl/auth/me/"),
      headers: {
        "Authorization": "Bearer $access",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode != 200) {
      await logout();
      throw Exception("Invalid session");
    }

    final data = jsonDecode(res.body);
    return Session(
      isAuthenticated: true,
      isPaid: data["has_lifetime_access"] == true,
    );
  }

  /// -----------------------------
  /// STRIPE CHECKOUT (Optional: backend-only)
  /// -----------------------------
  /// NOTE: App cannot redirect unpaid users to Stripe (Play Store compliance)
  /// This can be used for web or admin dashboards only.
  Future<String?> startStripeCheckout() async {
    final access = await getAccessToken();
    if (access == null) throw Exception("Not authenticated");

    final res = await http.post(
      Uri.parse("$_baseUrl/payments/stripe/create-checkout/"),
      headers: {
        "Authorization": "Bearer $access",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data["already_paid"] == true) {
        // Paid users are detected here, but app should never call this for unpaid
        throw Exception(data["message"] ?? "Already unlocked");
      }

      return data["checkout_url"];
    }

    throw Exception("Failed to start Stripe checkout");
  }

  Future<String?> getUsername() async {
    final token = await getAccessToken();
    if (token == null) return null;

    final payload = _parseJwt(token);
    return payload["username"];
  }

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    return jsonDecode(decoded);
  }

  Future<int?> getUserId() async {
    final token = await getAccessToken();
    if (token == null) return null;

    final payload = _parseJwt(token);
    final raw = payload["user_id"];

    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);

    return null;
  }

  









  /// -----------------------------
/// FETCH USER PROFILE
/// -----------------------------
  /// -----------------------------
/// FETCH FULL USER DATA
/// -----------------------------
  Future<Map<String, dynamic>> fetchUserData() async {
    await refreshIfNeeded();

    final access = await getAccessToken();
    if (access == null) throw Exception("Not authenticated");

    final res = await http.get(
      Uri.parse("$_baseUrl/auth/me2/"),
      headers: {
        "Authorization": "Bearer $access",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode != 200) {
      await logout();
      throw Exception("Failed to fetch user data");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }


  /// -----------------------------
  /// UPDATE PROFILE
  /// -----------------------------
  Future<void> updateProfile({
    required String displayName,
    required String bio,
    required String phone,
  }) async {
    final access = await getAccessToken();
    if (access == null) throw Exception("Not authenticated");

    final res = await http.put(
      Uri.parse("$_baseUrl/auth/profile/update/"), // make sure your backend URL matches
      headers: {
        "Authorization": "Bearer $access",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "display_name": displayName,
        "bio": bio,
        "phone": phone,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update profile");
    }
  }

  /// -----------------------------
  /// UPLOAD AVATAR
  /// -----------------------------
  Future<void> uploadAvatar(String filePath) async {
    final access = await getAccessToken();
    if (access == null) throw Exception("Not authenticated");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/auth/profile/upload-avatar/"), // backend URL
    );

    request.headers["Authorization"] = "Bearer $access";
    request.files.add(await http.MultipartFile.fromPath('avatar', filePath));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception("Failed to upload avatar");
    }
  }


  Future<void> forgotPassword(String email) async {
    await http.post(
      Uri.parse('$_baseUrl/auth/forgot-password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  Future<void> resetPassword({
    required String uid,
    required String token,
    required String newPassword,
  }) async {
    await http.post(
      Uri.parse('$_baseUrl/auth/reset-password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': uid,
        'token': token,
        'new_password': newPassword,
      }),
    );
  }



}
