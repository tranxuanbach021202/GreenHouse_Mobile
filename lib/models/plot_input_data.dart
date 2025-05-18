
class PlotInputData {
  final int blockIndex;
  final int plotIndex;
  final String treatmentCode;
  List<CriterionValue>? values;

  PlotInputData({
    required this.blockIndex,
    required this.plotIndex,
    required this.treatmentCode,
    this.values,
  });



  Map<String, dynamic> toJson() => {
    'blockIndex': blockIndex,
    'plotIndex': plotIndex,
    'treatmentCode': treatmentCode,
    'values': values?.map((v) => v.toJson()).toList() ?? [],
  };

  factory PlotInputData.fromJson(Map<String, dynamic> json) => PlotInputData(
    blockIndex: json['blockIndex'],
    plotIndex: json['plotIndex'],
    treatmentCode: json['treatmentCode'],
    values: (json['values'] as List)
        .map((e) => CriterionValue.fromJson(e))
        .toList(),
  );
}

class CriterionValue {
  final String criterionCode;
  final String criterionName;
  final double value;

  CriterionValue({
    required this.criterionCode,
    required this.criterionName,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
    'criterionCode': criterionCode,
    'criterionName': criterionName,
    'value': value,
  };


  factory CriterionValue.fromJson(Map<String, dynamic> json) {
    return CriterionValue(
      criterionCode: json['criterionCode'] as String,
      criterionName: json['criterionName'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }

}

