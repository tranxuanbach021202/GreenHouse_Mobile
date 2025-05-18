
import 'dart:io';

import 'package:dio/dio.dart';

import '../network_service/api_service.dart';
import '../network_service/app_exception.dart';
import '../network_service/cloud_storage_service.dart';
import '../network_service/network_url/app_network_urls.dart';
import '../utils/logger.dart';

class CloudRepository {
  final ApiService _apiService;
  final CloudStorageService _cloudStorageService;
  CloudRepository(this._apiService, this._cloudStorageService);

  Future<dynamic> getUploadUrl(
  {required dynamic data}
      ) async {

    try {
      final response = await _apiService.callPostApiResponse(
        url: AppNetworkUrls.uploadUrl,
        body: data,

      );
      logger.i(response.toString());
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }

  Future<bool> uploadFile({
    required String presignedUrl,
    required File file,
    required String contentType,
  }) async {
    try {
      logger.i("url upload" + presignedUrl);
      logger.i("image file " + file.toString());
      final response = await _cloudStorageService.uploadFile(
          presignedUrl: presignedUrl,
          file: file,
          contentType: contentType);
      if(response) {
        logger.i("upload thanh cong");
      }

      return true;
    } catch (e) {
      print('Error uploading file: $e');
      return false; // Lỗi khi upload
    }
  }


}