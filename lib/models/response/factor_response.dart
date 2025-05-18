
class FactorResponse {
  String id;
  dynamic projectId;
  String? factorCode;
  String? factorName;
  List<LevelResponse> levels;
  DateTime createdAt;
  DateTime updatedAt;

  FactorResponse({
    required this.id,
    required this.projectId,
    required this.factorCode,
    required this.factorName,
    required this.levels,
    required this.createdAt,
    required this.updatedAt,
  });




  factory FactorResponse.fromJson(Map<String, dynamic> json) => FactorResponse(
    id: json["id"],
    projectId: json["projectId"],
    factorCode: json["factorCode"],
    factorName: json["factorName"],
    levels: List<LevelResponse>.from(json["levels"].map((x) => LevelResponse.fromJson(x))),
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "projectId": projectId,
    "factorCode": factorCode,
    "factorName": factorName,
    "levels": List<dynamic>.from(levels.map((x) => x.toJson())),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}

class LevelResponse {
  dynamic id;
  String levelCode;
  String levelName;


  LevelResponse({
    required this.id,
    required this.levelCode,
    required this.levelName,
  });

  LevelResponse.simple({
    required this.levelCode,
    required this.levelName,
  })
      : id = null;

  factory LevelResponse.fromJson(Map<String, dynamic> json) => LevelResponse(
    id: json["id"],
    levelCode: json["levelCode"],
    levelName: json["levelName"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "levelCode": levelCode,
    "levelName": levelName,
  };
}