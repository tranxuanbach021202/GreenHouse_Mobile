class InvitationModel {
  final String id;
  final String projectId;
  final String projectName;
  final String? thumbnailUrlProject;
  final String inviterId;
  final String inviterName;
  final String invitedUserId;
  final String invitedUserName;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvitationModel({
    required this.id,
    required this.projectId,
    required this.projectName,
    this.thumbnailUrlProject,
    required this.inviterId,
    required this.inviterName,
    required this.invitedUserId,
    required this.invitedUserName,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'],
      projectId: json['projectId'],
      projectName: json['projectName'],
      thumbnailUrlProject: json['thumbnailUrlProject'],
      inviterId: json['inviterId'],
      inviterName: json['inviterName'],
      invitedUserId: json['invitedUserId'],
      invitedUserName: json['invitedUserName'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'projectName': projectName,
      'thumbnailUrlProject': thumbnailUrlProject,
      'inviterId': inviterId,
      'inviterName': inviterName,
      'invitedUserId': invitedUserId,
      'invitedUserName': invitedUserName,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
