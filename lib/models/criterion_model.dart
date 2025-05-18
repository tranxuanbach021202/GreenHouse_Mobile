class Criterion {
  final String? id;
  final String criterionCode;
  final String criterionName;

  Criterion({
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