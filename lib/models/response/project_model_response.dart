import 'package:greenhouse/models/response/project_member_response.dart';

class ProjectModelResponse {
  final String id;
  final String projectCode;
  final String projectName;
  final String thumbnailUrl;
  final List<ProjectMemberResponse> members;
  final DateTime startDate;
  final DateTime endDate;

  ProjectModelResponse({
    required this.id,
    required this.projectCode,
    required this.projectName,
    required this.thumbnailUrl,
    required this.members,
    required this.startDate,
    required this.endDate,
  });

  factory ProjectModelResponse.fromJson(Map<String, dynamic> json) {
    return ProjectModelResponse(
      id: json['id'],
      projectCode: json['projectCode'] ?? '',
      projectName: json['projectName'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      members: (json['members'] as List<dynamic>? ?? [])
          .map((e) => ProjectMemberResponse.fromJson(e))
          .toList(),
      startDate: DateTime.parse(json["startDate"]),
      endDate: DateTime.parse(json["endDate"]),
    );
  }
}
