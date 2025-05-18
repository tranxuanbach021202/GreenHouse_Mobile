
import 'package:greenhouse/models/plot_model.dart';
import 'package:greenhouse/models/response/criterion_response.dart';
import 'package:greenhouse/models/response/factor_response.dart';
import 'package:greenhouse/models/response/project_member_response.dart';
import 'package:greenhouse/models/response/treatment_response.dart';

class ProjectResponse {
  String id;
  String code;
  String name;
  DateTime startDate;
  DateTime endDate;
  String description;
  String thumbnailUrl;
  List<ProjectMemberResponse> members;
  FactorResponse factor;
  List<CriterionResponse> criteria;
  List<TreatmentResponse> treatments;
  String experimentType;
  int blocks;
  int replicates;
  int columns;
  List<List<PlotModel>> layout;
  bool isPublic;

  ProjectResponse({
    required this.id,
    required this.code,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.thumbnailUrl,
    required this.members,
    required this.factor,
    required this.criteria,
    required this.treatments,
    required this.experimentType,
    required this.blocks,
    required this.replicates,
    required this.columns,
    required this.layout,
    required this.isPublic
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) => ProjectResponse(
    id: json["id"],
    code: json["code"],
    name: json["name"],
    startDate: DateTime.parse(json["startDate"]),
    endDate: DateTime.parse(json["endDate"]),
    description: json["description"],
    thumbnailUrl: json["thumbnailUrl"],
    members: List<ProjectMemberResponse>.from(
        json["members"].map((x) => ProjectMemberResponse.fromJson(x))),
    factor: FactorResponse.fromJson(json["factor"]),
    criteria: List<CriterionResponse>.from(
        json["criteria"].map((x) => CriterionResponse.fromJson(x))),
    treatments: List<TreatmentResponse>.from(
        json["treatments"].map((x) => TreatmentResponse.fromJson(x))),
    experimentType: json["experimentType"],
    blocks: json["blocks"],
    replicates: json["replicates"],
    columns: json["columns"],
    layout: List<List<PlotModel>>.from(json["layout"]
        .map((x) => List<PlotModel>.from(x.map((x) => PlotModel.fromJson(x))))),
    isPublic: json["isPublic"] ?? false, //
  );


  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "startDate": startDate.toIso8601String(),
    "endDate": endDate.toIso8601String(),
    "description": description,
    "thumbnailUrl": thumbnailUrl,
    "members": List<dynamic>.from(members.map((x) => x.toJson())),
    "factor": factor.toJson(),
    "criteria": List<dynamic>.from(criteria.map((x) => x)),
    "treatments": List<dynamic>.from(treatments.map((x) => x.toJson())),
    "experimentType": experimentType,
    "blocks": blocks,
    "replicates": replicates,
    "columns": columns,
    "layout": List<dynamic>.from(layout.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
    "isPublic": isPublic,
  };
}