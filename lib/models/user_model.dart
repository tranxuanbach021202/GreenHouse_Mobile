class User {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? role;
  final String? urlAvatar;
  final String? bio;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.role,
    this.urlAvatar,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      role: json['role'] ?? '',
      urlAvatar: json['urlAvatar'] ?? '',
      bio: json['bio'] ?? ''
    );
  }
}