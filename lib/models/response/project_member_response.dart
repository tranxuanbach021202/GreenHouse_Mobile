class ProjectMemberResponse {
  String userId;
  String userName;
  String email;
  String displayName;
  String urlAvatar;
  String role;

  ProjectMemberResponse({
    required this.userId,
    required this.userName,
    required this.email,
    required this.displayName,
    required this.urlAvatar,
    required this.role,
  });

  factory ProjectMemberResponse.fromJson(Map<String, dynamic> json) => ProjectMemberResponse(
    userId: json["userId"] ?? '',
    userName: json["userName"] ?? '',
    email: json["email"] ?? '',
    displayName: json["displayName"] ?? '',
    urlAvatar: json["urlAvatar"] ?? '',
    role: json["role"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "userName": userName,
    "email": email,
    "displayName": displayName,
    "urlAvatar": urlAvatar,
    "role": role,
  };
}