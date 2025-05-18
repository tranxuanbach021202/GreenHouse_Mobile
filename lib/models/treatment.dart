class Treatment {
  final String code;
  final String name;

  Treatment({
    required this.code,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name
  };
}


