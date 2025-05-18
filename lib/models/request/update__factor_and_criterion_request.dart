import 'package:greenhouse/models/plot_model.dart';

class UpdateFactorAndCriterionRequest {
  final String factorId;
  final String factorCode;
  final String factorName;
  final List<LevelRequest> levels;
  final List<CriterionRequest> criteria;

  final String experimentType; // 'RCD' hoặc 'RCBD'
  final int blocks;
  final int replicates;
  final int columns;
  final List<List<PlotModel>> layout;


  UpdateFactorAndCriterionRequest({
    required this.factorId,
    required this.factorCode,
    required this.factorName,
    required this.levels,
    required this.criteria,
    required this.experimentType,
    required this.blocks,
    required this.replicates,
    required this.columns,
    required this.layout,
  });

  Map<String, dynamic> toJson() => {
    "factorId": factorId,
    "factorCode": factorCode,
    "factorName": factorName,
    "levels": levels.map((e) => e.toJson()).toList(),
    "criteria": criteria.map((e) => e.toJson()).toList(),
    "experimentType": experimentType,
    "blocks": blocks,
    "replicates": replicates,
    "columns": columns,
    "layout": layout.map((row) => row.map((cell) => cell.toJson()).toList()).toList(),
  };
}


class LevelRequest {
  final String? id;
  final String levelCode;
  final String levelName;

  LevelRequest({
    this.id,
    required this.levelCode,
    required this.levelName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'levelCode': levelCode,
    'levelName': levelName,
  };
}

class CriterionRequest {
  final String? id;
  final String criterionCode;
  final String criterionName;

  CriterionRequest({
    this.id,
    required this.criterionCode,
    required this.criterionName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'criterionCode': criterionCode,
    'criterionName': criterionName,
  };
}