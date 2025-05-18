
class CriterionResponse {
  String id;
  String criterionCode;
  String criterionName;
  DateTime createdAt;
  DateTime updatedAt;

  CriterionResponse({
    required this.id,
    required this.criterionCode,
    required this.criterionName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CriterionResponse.fromJson(Map<String, dynamic> json) => CriterionResponse(
    id: json["id"],
    criterionCode: json["criterionCode"],
    criterionName: json["criterionName"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "criterionCode": criterionCode,
    "criterionName": criterionName,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}