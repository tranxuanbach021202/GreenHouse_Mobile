class PlotModel {
  String idTreatment;
  String treatmentCode;
  dynamic? plantName;

  PlotModel({
    required this.idTreatment,
    required this.treatmentCode,
    required this.plantName,
  });

  factory PlotModel.fromJson(Map<String, dynamic> json) => PlotModel(
    idTreatment: json["idTreatment"],
    treatmentCode: json["treatmentCode"],
    plantName: json["plantName"]
  );

  Map<String, dynamic> toJson() => {
    "idTreatment": idTreatment,
    "treatmentCode": treatmentCode,
    "plantName": plantName,
  };
}