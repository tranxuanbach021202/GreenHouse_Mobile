import '../plot_input_data.dart';

class MeasurementRequest {
  final String projectId;
  final String start;
  final String end;
  final List<PlotInputData> records;

  MeasurementRequest({
    required this.projectId,
    required this.start,
    required this.end,
    required this.records,
  });

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'start': start,
    'end': end,
    'records': records.map((e) => e.toJson()).toList(),
  };
}
