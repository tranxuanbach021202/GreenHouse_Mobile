import 'package:greenhouse/models/enums/experiment_type.dart';
import 'package:greenhouse/models/project_member.dart';
import 'package:greenhouse/models/treatment.dart';

import 'criterion_model.dart';
import 'factor_model.dart';

class Project {
  final String code;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final String? thumbnailUrl;
  final List<ProjectMember> members;
  final Factor factor;
  final List<Criterion> criteria;
  final List<Treatment> treatments;
  final ExperimentType experimentType;
  final int blocks;
  final int replicates;
  final int columns;
  final List<List<String>> layout;

  Project({
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
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'description': description,
    'thumbnailUrl': thumbnailUrl,
    'members': members.map((member) => member.toJson()).toList(),
    'factor': factor.toJson(),
    'criteria': criteria.map((criterion) => criterion.toJson()).toList(),
    'treatments': treatments.map((t) => t.toJson()).toList(),
    'experimentType': experimentType,
    'blocks': blocks,
    'replicates': replicates,
    'columns': columns,
    'layout': layout
  };
}