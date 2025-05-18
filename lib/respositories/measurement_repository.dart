
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:greenhouse/models/plot_input_data.dart';

import '../models/request/measurement_request.dart';
import '../models/request/measurements_request.dart';
import '../models/response/api_response.dart';
import '../models/response/edit_session_history_response.dart';
import '../models/response/measurement_detail_response.dart';
import '../network_service/api_service.dart';
import '../network_service/app_exception.dart';
import '../network_service/network_url/app_network_urls.dart';
import '../utils/logger.dart';

class MeasurementRepository {
  final ApiService _apiService;
  MeasurementRepository(this._apiService);

  Future<dynamic> createMeasurementPeriod(MeasurementsRequest request) async {
    try {
      final response = await _apiService.callPostApiResponse(
        url: AppNetworkUrls.measurement,
        body: request.toJson(),
      );
      logger.i("Tạo đợt nhập thành công");
      logger.i(response.toString());
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }

  Future<dynamic> updateMeasurementById(String id, MeasurementsRequest request) async {
    try {
      final response = await _apiService.callPutApiResponse(
        url: "${AppNetworkUrls.measurement}/$id",
        body: request.toJson(),
      );
      logger.i("Cập nhật đợt nhập thành công: $response");
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }


  Future<void> deleteMeasurement(String id) async {
    try {
      final response = await _apiService.callDeleteApiResponse(
        url: AppNetworkUrls.measurement + "/$id", body: null,
      );
      logger.i("Đã xoá measurement: $response");
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> appendRecordsToMeasurement(String measurementId, List<PlotInputData> records) async {
    try {
      final body = {
        'records': records.map((r) => r.toJson()).toList(),
      };

      final response = await _apiService.callPostApiResponse(
        url: '${AppNetworkUrls.measurement}/$measurementId/create-record',
        body: body,
      );

      logger.i('✅ Thêm đợt nhập đầu tiên thành công: $response');
    } catch (e) {
      logger.e('❌ Lỗi khi gửi dữ liệu đợt nhập đầu tiên: $e');
      rethrow;
    }
  }

  Future<String?> createNewMeasurement({
    required String projectId,
    required DateTime start,
    required DateTime end,
    required List<PlotInputData> records,
  }) async {
    try {
      final body = {
        'projectId': projectId,
        'start': start.toIso8601String().split('T').first,
        'end': end.toIso8601String().split('T').first,
        'records': records.map((r) => r.toJson()).toList(),
      };

      final response = await _apiService.callPostApiResponse(
        url: AppNetworkUrls.measurement + "/new" , // => ví dụ: /api/measurements
        body: body,
      );

      logger.i('✅ Tạo đợt nhập mới thành công: $response');

      // Trả về ID của measurement nếu có
      if (response is Map<String, dynamic>) {
        return response['id']?.toString();
      }

      return null;
    } catch (e) {
      logger.e('❌ Lỗi khi tạo đợt nhập mới: $e');
      rethrow;
    }
  }





  Future<dynamic> getMeasurement(String projectId) async {
    try {
      final response = await _apiService.callGetApiResponse(
          url: AppNetworkUrls.measurement + '/project/' + projectId
      );
      logger.i(response.toString());
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }


  Future<dynamic> getMeasurementById(String measurementId) async {
    try {
      final response = await _apiService.callGetApiResponse(
          url: AppNetworkUrls.measurement +"/" + measurementId
      );
      logger.i("submit data 5");
      logger.i(response.toString());
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }


  Future<dynamic> updateMeasurementRecords(String id, List<PlotInputData> records) async {
    try {
      final body = {
        'records': records.map((r) => r.toJson()).toList(),
      };

      logger.i("📤 Payload gửi cập nhật records:\n$body");

      final response = await _apiService.callPutApiResponse(
        url: "${AppNetworkUrls.measurement}/$id/data",
        body: body,
      );

      logger.i("✅ Gửi dữ liệu records thành công: $response");
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }


  Future<dynamic> getEditHistory(String measurementId) async {
    try {
      final response = await _apiService.callGetApiResponse(
        url: '${AppNetworkUrls.measurement}/$measurementId/history',
      );

      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }


  Future<Uint8List> exportMeasurementData(String projectId) async {
    try {
      final response = await _apiService.callGetApiResponse(
        url: "${AppNetworkUrls.measurement}/export/data",
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          },
        ),
        parameters: {
          'projectId': projectId,
        },
      );
      return Uint8List.fromList(response);
    } on DioException catch (e) {
      logger.i("Export" + e.message.toString());
      throw Exception("Export failed: ${e.message}");
    }
  }









}
