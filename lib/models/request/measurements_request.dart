
import 'package:intl/intl.dart';

class MeasurementsRequest {
  final String projectId;
  final DateTime start;
  final DateTime end;

  MeasurementsRequest({
    required this.projectId,
    required this.start,
    required this.end
  });

  Map<String, dynamic> toJson() => {
    "projectId": projectId,
    "start": DateFormat("yyyy-MM-dd").format(start),
    "end": DateFormat("yyyy-MM-dd").format(end),
  };
}
