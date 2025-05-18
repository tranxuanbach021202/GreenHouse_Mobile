class ProjectPublicRequest {
  final bool isPublic;

  ProjectPublicRequest({required this.isPublic});

  Map<String, dynamic> toJson() => {
    'isPublic': isPublic,
  };
}
