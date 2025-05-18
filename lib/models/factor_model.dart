
import 'level_model.dart';

class Factor {
  final String? code;
  final String? name;
  final List<Level> levels;

  Factor({
    required this.code,
    required this.name,
    required this.levels,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'levels': levels.map((level) => level.toJson()).toList(),
  };
}