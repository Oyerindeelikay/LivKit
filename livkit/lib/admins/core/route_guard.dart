import '../services/admin_auth_service.dart';

class AdminRouteGuard {
  final _auth = AdminAuthService();

  Future<bool> canAccessAdmin() async {
    final token = await _auth.getAccessToken();
    return token != null;
  }

  Future<bool> isMainAdmin() async {
    final role = await _auth.getRole();
    return role == "ADMIN_MAIN";
  }
}
