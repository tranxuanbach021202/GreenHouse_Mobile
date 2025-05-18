import 'package:greenhouse/models/enums/project_role.dart';
import 'package:greenhouse/models/response/project_member_response.dart';

class ProjectMember {
  final String userId;
  final String email;
  final String? name;
  final String? urlAvatar;
  final ProjectRole role;

  ProjectMember({
    required this.userId,
    required this.email,
    this.name,
    this.urlAvatar,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'name': name,
    'urlAvatar': urlAvatar,
    'role': role.toString().split('.').last,
  };

  factory ProjectMember.fromResponse(ProjectMemberResponse response) {
    return ProjectMember(
      userId: response.userId,
      email: response.email,
      name: response.userName,
      urlAvatar: response.urlAvatar,
      role: _mapStringToProjectRole(response.role),
    );
  }

  static ProjectRole _mapStringToProjectRole(String roleStr) {
    switch (roleStr.toUpperCase()) {
      case 'OWNER':
        return ProjectRole.OWNER;
      case 'MEMBER':
        return ProjectRole.MEMBER;
      case 'GUEST':
        return ProjectRole.GUEST;
      default:
        return ProjectRole.MEMBER;
    }
  }
}