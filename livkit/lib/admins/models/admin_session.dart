class AdminSession {
  final String accessToken;
  final String refreshToken;
  final String role;

  AdminSession({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
  });

  factory AdminSession.fromJson(Map<String, dynamic> json) {
    return AdminSession(
      accessToken: json["access"],
      refreshToken: json["refresh"],
      role: json["role"],
    );
  }
}
