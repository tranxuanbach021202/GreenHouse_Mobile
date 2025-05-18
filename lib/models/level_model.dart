class Level {
  final String? id;
  final String code;
  final String name;

  Level({
    this.id,
    required this.code,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}