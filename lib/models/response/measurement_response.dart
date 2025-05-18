class MeasurementResponse {
  String id;
  String projectId;
  String userId;
  DateTime start;
  DateTime end;
  DateTime createdAt;

  MeasurementResponse({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.start,
    required this.end,
    required this.createdAt,
  });

  factory MeasurementResponse.fromJson(Map<String, dynamic> json) => MeasurementResponse(
    id: json["id"],
    projectId: json["projectId"],
    userId: json["userId"],
    start: DateTime.parse(json["start"]),
    end: DateTime.parse(json["end"]),
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "projectId": projectId,
    "userId": userId,
    "start": "${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}",
    "end": "${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}",
    "createdAt": createdAt.toIso8601String(),
  };
}