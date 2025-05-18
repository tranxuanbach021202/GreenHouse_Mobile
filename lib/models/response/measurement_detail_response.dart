import 'dart:convert';
import 'package:greenhouse/models/plot_input_data.dart';

import '../../utils/safe_parse.dart';

class MeasurementDetailResponse {
  final String? id;
  final String? projectId;
  final String? userId;
  final List<CriterionList> criterionList;
  final CreatedBy? createdBy;
  final DateTime? start;
  final DateTime? end;
  final DateTime? createdAt;
  final List<PlotInputData>? records;

  MeasurementDetailResponse({
    this.id,
    this.projectId,
    this.userId,
    this.criterionList = const [],
    this.createdBy,
    this.start,
    this.end,
    this.createdAt,
    this.records = const [],
  });

  factory MeasurementDetailResponse.fromRawJson(String str) =>
      MeasurementDetailResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MeasurementDetailResponse.fromJson(Map<String, dynamic> json) {
    return MeasurementDetailResponse(
      id: json["id"],
      projectId: json["projectId"],
      userId: json["userId"],
      criterionList: (json["criterionList"] is List)
          ? List<CriterionList>.from(
          json["criterionList"].map((x) => CriterionList.fromJson(x)))
          : [],
      createdBy: json["createdBy"] == null
          ? null
          : CreatedBy.fromJson(json["createdBy"]),
      start: tryParseDate(json["start"]),
      end: tryParseDate(json["end"]),
      createdAt: tryParseDate(json["createdAt"]),
      records: (json["records"] is List)
          ? List<PlotInputData>.from(
          json["records"].map((x) => PlotInputData.fromJson(x)))
          : [],

    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "projectId": projectId,
    "userId": userId,
    "criterionList":
    List<dynamic>.from(criterionList.map((x) => x.toJson())),
    "createdBy": createdBy?.toJson(),
    "start": start?.toIso8601String(),
    "end": end?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "records": List<dynamic>.from(records!.map((x) => x.toJson())),
  };
}

class CreatedBy {
  final String? id;
  final String? username;
  final String? email;
  final dynamic urlAvatar;
  final dynamic createdAt;

  CreatedBy({
    this.id,
    this.username,
    this.email,
    this.urlAvatar,
    this.createdAt,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    urlAvatar: json["urlAvatar"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "urlAvatar": urlAvatar,
    "createdAt": createdAt,
  };
}

class CriterionList {
  final String? id;
  final String? projectId;
  final String? criterionCode;
  final String? criterionName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CriterionList({
    this.id,
    this.projectId,
    this.criterionCode,
    this.criterionName,
    this.createdAt,
    this.updatedAt,
  });

  factory CriterionList.fromJson(Map<String, dynamic> json) => CriterionList(
    id: json["id"],
    projectId: json["projectId"],
    criterionCode: json["criterionCode"],
    criterionName: json["criterionName"],
    createdAt: tryParseDate(json["createdAt"]),
    updatedAt: tryParseDate(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "projectId": projectId,
    "criterionCode": criterionCode,
    "criterionName": criterionName,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

// class Record {
//   final int? blockIndex;
//   final int? plotIndex;
//   final String? treatmentCode;
//   final List<Value> values;
//
//   Record({
//     this.blockIndex,
//     this.plotIndex,
//     this.treatmentCode,
//     this.values = const [],
//   });
//
//   factory Record.fromJson(Map<String, dynamic> json) => Record(
//     blockIndex: tryParseInt(json["blockIndex"]),
//     plotIndex: tryParseInt(json["plotIndex"]),
//     treatmentCode: json["treatmentCode"],
//     values: (json["values"] is List)
//         ? List<Value>.from(json["values"].map((x) => Value.fromJson(x)))
//         : [],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "blockIndex": blockIndex,
//     "plotIndex": plotIndex,
//     "treatmentCode": treatmentCode,
//     "values": List<dynamic>.from(values.map((x) => x.toJson())),
//   };
// }
//
// class Value {
//   final String? criterionCode;
//   final String? criterionName;
//   final double? value;
//
//   Value({
//     this.criterionCode,
//     this.criterionName,
//     this.value,
//   });
//
//   factory Value.fromJson(Map<String, dynamic> json) => Value(
//     criterionCode: json["criterionCode"],
//     criterionName: json["criterionName"],
//     value: (json["value"] as num?)?.toDouble(),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "criterionCode": criterionCode,
//     "criterionName": criterionName,
//     "value": value,
//   };
// }
