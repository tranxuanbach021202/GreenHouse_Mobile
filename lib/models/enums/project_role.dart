enum ProjectRole {
  OWNER,
  MEMBER,
  GUEST,
}

extension ProjectRoleExtension on ProjectRole {
  String get value => toString().split('.').last;

  static ProjectRole fromString(String? role) {
    if (role == null) return ProjectRole.GUEST;
    return ProjectRole.values.firstWhere(
          (e) => e.value == role.toUpperCase(),
      orElse: () => ProjectRole.GUEST,
    );
  }
}
