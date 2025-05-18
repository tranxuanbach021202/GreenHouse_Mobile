import 'package:dio/dio.dart';
import 'package:greenhouse/network_service/network_url/app_network_urls.dart';
import 'package:greenhouse/utils/logger.dart';
import '../network_service/api_service.dart';
import '../network_service/app_exception.dart';

class UserRepository {
  final ApiService _apiService;
  UserRepository(this._apiService);

  Future<dynamic> searchUsers({
    required int page,
    required int size,
    required String sortBy,
    required String sortDir,
    String? search,
  }) async {
    logger.i("search " + search.toString());
    try {
      final response = await _apiService.callGetApiResponse(
        url: AppNetworkUrls.users,
        parameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'sortDir': sortDir,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }


  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiService.callGetApiResponse(
          url: AppNetworkUrls.users + "/profile",
      );
      logger.i(response.toString());
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }



  Future<dynamic> updateProfile(String name, String urlAvartar, String bio) async {
    try {
      final response = await _apiService.callPutApiResponse(
        url: AppNetworkUrls.updateProfile,
        body: {
          "displayName": name,
          "urlAvatar": urlAvartar,
          "bio": bio
        }
      );
      logger.i(response.toString());
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }


}