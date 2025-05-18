import 'package:greenhouse/models/enums/experiment_type.dart';

class ExperimentLayout {
  final int blocks;
  final int replicates;
  final int columnsInBlock;
  final ExperimentType designType;
  final List<List<String>> layout;

  ExperimentLayout({
    required this.blocks,
    required this.replicates,
    required this.columnsInBlock,
    required this.designType,
    required this.layout,
  });

  Map<String, dynamic> toJson() => {
    'blocks': blocks,
    'replicates': replicates,
    'columnsInBlock': columnsInBlock,
    'designType': designType,
    'layout': layout,
  };
}


