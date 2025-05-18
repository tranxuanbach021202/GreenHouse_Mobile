class UpdateProjectMembersRequest {
  final List<MemberUpdateItem> updates;
  final List<MemberInviteItem> invites;

  UpdateProjectMembersRequest({
    required this.updates,
    required this.invites,
  });

  Map<String, dynamic> toJson() => {
    'updates': updates.map((e) => e.toJson()).toList(),
    'invites': invites.map((e) => e.toJson()).toList(),
  };
}

class MemberUpdateItem {
  final String userId;
  final String role;
  final bool remove;

  MemberUpdateItem({
    required this.userId,
    required this.role,
    required this.remove,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'role': role,
    'remove': remove,
  };
}

class MemberInviteItem {
  final String userId;
  final String email;
  final String name;
  final String role;

  MemberInviteItem({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'name': name,
    'role': role,
  };
}
