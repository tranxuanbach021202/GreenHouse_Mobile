import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../base/services/navigation_service.dart';
import '../../../../di/di.dart';
import '../../../../models/request/measurements_request.dart';
import '../../../../models/response/measurement_response.dart';
import '../../../../models/response/project_response.dart';
import '../../../../network_service/app_exception.dart';
import '../../../../respositories/measurement_repository.dart';
import '../../../../utils/logger.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:greenhouse/base/viewmodels/base_view_model.dart';
import 'package:greenhouse/models/response/project_response.dart';
import 'package:greenhouse/models/response/measurement_response.dart';
import 'package:greenhouse/respositories/measurement_repository.dart';
import 'package:greenhouse/models/request/measurement_request.dart';
import 'package:greenhouse/network_service/app_exception.dart';
import 'package:greenhouse/utils/logger.dart';

class AddMeasurementViewModel extends BaseViewModel {
  MeasurementResponse? editingMeasurement;
  final MeasurementRepository _measurementRepository;

  AddMeasurementViewModel({required MeasurementRepository measurementRepository})
      : _measurementRepository = measurementRepository;

  DateTime? startDate;
  DateTime? endDate;

  void setStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }



  void setMeasurementToEdit(MeasurementResponse measurement) {
    logger.i(measurement.start.toString());
    editingMeasurement = measurement;
    startDate = measurement.start;
    endDate = measurement.end;
  }


  Future<void> submit(ProjectResponse project, List<MeasurementResponse> measurements) async {
    if (startDate == null || endDate == null) {
      setError("Vui lòng chọn ngày bắt đầu và kết thúc");
      return;
    }

    if (!isValidRange(
        project,
        measurements,
        editingMeasurement: editingMeasurement
    )) {
      notifyListeners();
      return;
    }

    isLoading = true;
    clearError();

    try {
      final request = MeasurementsRequest(
        projectId: project.id,
        start: startDate!,
        end: endDate!,
      );

      if (editingMeasurement != null) {
        // update
        await _measurementRepository.updateMeasurementById(editingMeasurement!.id, request);
      } else {
        // create
        await _measurementRepository.createMeasurementPeriod(request);
      }

      getIt<NavigationService>().pop(true);

    } on ApiException catch (e) {
      setError(e.message);
    } catch (e) {
      setError("Đã xảy ra lỗi. Vui lòng thử lại.");
    } finally {
      isLoading = false;
    }
  }






  Future<void> setStartDateFromPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setStartDate(picked);
    }
  }

  Future<void> setEndDateFromPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setEndDate(picked);
    }
  }

  bool isValidRange(
      ProjectResponse project,
      List<MeasurementResponse> existingMeasurements,
      {MeasurementResponse? editingMeasurement}
      ) {
    if (startDate == null || endDate == null) return false;

    if (startDate!.isBefore(project.startDate) || endDate!.isAfter(project.endDate)) {
      setError('Thời gian nhập phải nằm trong khoảng thời gian của dự án');
      return false;
    }

    for (final m in existingMeasurements) {
      // Bỏ qua việc kiểm tra với đợt đo đang chỉnh sửa
      if (editingMeasurement != null && m.id == editingMeasurement.id) {
        continue; // Bỏ qua đợt đo đang chỉnh sửa
      }

      final overlap = !(endDate!.isBefore(m.start) || startDate!.isAfter(m.end));
      if (overlap) {
        setError('Đợt nhập trùng với khoảng thời gian đã tồn tại');
        return false;
      }
    }

    return true;
  }


  @override
  FutureOr<void> init() async {
    clearError();
  }
}
