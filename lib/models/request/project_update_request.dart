class ProjectUpdateRequest {
  final String projectCode;
  final String projectName;
  final String thumbnailUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;

  ProjectUpdateRequest({
    required this.projectCode,
    required this.projectName,
    required this.thumbnailUrl,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    "projectCode": projectCode,
    "projectName": projectName,
    "thumbnailUrl": thumbnailUrl,
    "startDate": startDate.toIso8601String(),
    "endDate": endDate.toIso8601String(),
    "description": description,
  };
}
