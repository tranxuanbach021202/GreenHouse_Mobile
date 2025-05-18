import '../../models/response/project_member_response.dart';

class ProjectShort {
  final String id;
  final String projectCode;
  final String projectName;
  final String? description;
  final String experimentType;
  final String? thumbnailUrl;
  List<ProjectMemberResponse>? members;
  final DateTime startDate;
  final DateTime endDate;

  ProjectShort({
    required this.id,
    required this.projectCode,
    required this.projectName,
    this.description,
    this.thumbnailUrl,
    this.members,
    required this.experimentType,
    required this.startDate,
    required this.endDate,
  });

  factory ProjectShort.fromJson(Map<String, dynamic> json) {
    return ProjectShort(
      id: json['id'],
      projectCode: json['projectCode'],
      projectName: json['projectName'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => ProjectMemberResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      experimentType: json['experimentType'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}
