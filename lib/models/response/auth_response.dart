

class AuthResponse {
  final String token;
  final String type;
  final String refreshToken;
  final String id;
  final String username;
  final String email;
  final String role;

  AuthResponse({
    required this.token,
    required this.type,
    required this.refreshToken,
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      type: json['type'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'type': type,
    'refreshToken': refreshToken,
    'id': id,
    'username': username,
    'email': email,
    'role': role,
  };
}
