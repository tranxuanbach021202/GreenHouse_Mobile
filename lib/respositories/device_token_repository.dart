

import 'package:dio/dio.dart';

import '../models/request/device_token_request.dart';
import '../network_service/api_service.dart';
import '../network_service/app_exception.dart';
import '../network_service/network_url/app_network_urls.dart';
import '../utils/logger.dart';

class DeviceTokenRepository {
  final ApiService _apiService;
  DeviceTokenRepository(this._apiService);
  Future<void> syncDeviceToken(DeviceTokenRequest request) async {
    try {
      final response = await _apiService.callPostApiResponse(
          url: AppNetworkUrls.device_token,
          body: request.toJson());
      print("✅ Gửi token thành công!");
    } on DioException catch (e) {
      logger.e("Sync Device Token error \n" + e.toString());
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }
}
