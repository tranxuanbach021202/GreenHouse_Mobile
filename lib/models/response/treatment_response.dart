class TreatmentResponse {
  String id;
  String projectId;
  String? treatmentCode;
  String? treatmentName;
  String? factorId;
  dynamic levelId;
  DateTime createdAt;
  DateTime updatedAt;

  TreatmentResponse({
    required this.id,
    required this.projectId,
    required this.treatmentCode,
    required this.treatmentName,
    required this.factorId,
    required this.levelId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TreatmentResponse.fromJson(Map<String, dynamic> json) => TreatmentResponse(
    id: json["id"],
    projectId: json["projectId"],
    treatmentCode: json["treatmentCode"],
    treatmentName: json["treatmentName"],
    factorId: json["factorId"],
    levelId: json["levelId"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "projectId": projectId,
    "treatmentCode": treatmentCode,
    "treatmentName": treatmentName,
    "factorId": factorId,
    "levelId": levelId,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}