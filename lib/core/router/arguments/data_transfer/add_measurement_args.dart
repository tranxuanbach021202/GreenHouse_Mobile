import '../../../../models/response/measurement_response.dart';
import '../../../../models/response/project_response.dart';

class AddMeasurementArgs {
  final ProjectResponse project;
  final List<MeasurementResponse> measurements;
  final MeasurementResponse? measurementToEdit;

  AddMeasurementArgs({
    required this.project,
    required this.measurements,
    this.measurementToEdit,
  });
}
