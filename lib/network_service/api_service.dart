import 'package:dio/dio.dart';

import '../base/services/base_api_service.dart';
import '../base/services/storage_service.dart';
import '../di/di.dart';
import '../models/response/auth_response.dart';
import '../utils/logger.dart';
import 'network_url/app_network_urls.dart';

class ApiService extends BaseApiServices {
  static Dio? _dio;
  static final StorageService _storageService = getIt<StorageService>();

  static Future<Dio> get instance async {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            try {
              // Xử lý base URL
              if (!options.path.contains('http')) {
                options.path = AppNetworkUrls.baseUrl + options.path;
              }

              // Cấu hình timeout
              options.connectTimeout = const Duration(seconds: 15);
              options.receiveTimeout = const Duration(seconds: 15);

              // Lấy token từ StorageService
              final token = _storageService.getToken();
              final refreshToken = _storageService.getRefreshToken();
              final tokenType = _storageService.getTokenType();

              // Kiểm tra xem có token hay không
              if (token == null || refreshToken == null) {
                return handler.next(options);
              }

              // Thêm token vào header
              options.headers['Authorization'] = "$tokenType $token";

              logger.d('Request Headers: ${options.headers}');
              logger.d('Request URL: ${options.path}');

              return handler.next(options);
            } catch (e) {
              logger.e('Error in request interceptor: $e');
              return handler.next(options);
            }
          },
          onResponse: (response, handler) {
            logger.d('Response: ${response.data}');
            return handler.next(response);
          },
          onError: (DioException error, handler) async {
            logger.e('API Error: ${error.message}', error: error);

            if (error.response?.statusCode == 401) {
              try {
                final refreshToken = _storageService.getRefreshToken();
                if (refreshToken != null) {
                  final response = await _dio!.post(
                    '${AppNetworkUrls.baseUrl}/auth/refresh-token',
                    data: {'refreshToken': refreshToken},
                  );

                  if (response.statusCode == 200 && response.data != null) {
                    // Giả sử response trả về AuthResponse
                    final authResponse = AuthResponse.fromJson(response.data);

                    // Lưu token mới
                    await _storageService.saveAuthData(authResponse);

                    // Thử lại request ban đầu với token mới
                    final originalRequest = error.requestOptions;
                    originalRequest.headers['Authorization'] =
                    "${authResponse.type} ${authResponse.token}";

                    final newResponse = await _dio!.fetch(originalRequest);
                    return handler.resolve(newResponse);
                  }
                }
              } catch (refreshError) {
                logger.e('Error refreshing token: $refreshError');
              }

              // Nếu refresh token thất bại hoặc không có refresh token
              await logout();
            }
            return handler.next(error);
          },
        ),
      );
    }
    return _dio!;
  }

  static Future<void> logout() async {
    try {
      final dio = await instance;


      await dio.post(AppNetworkUrls.logout);


      await _storageService.clearAuth();


      reset();

      logger.i('Logout thành công');
    } catch (e) {
      logger.e('Lỗi khi logout: $e');
    }
  }


  static void reset() {
    _dio = null;
  }

  // Các phương thức API calls giữ nguyên
  @override
  Future<dynamic> callGetApiResponse({
    required String url,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? myHeaders,
    Options? options,
  }) async {
    try {
      logger.i("paramater:" + parameters.toString());
      final dio = await instance;
      final response = await dio.get(
        url,
        queryParameters: parameters,
        options: options ?? Options(headers: myHeaders),
      );
      return response.data;
    } on DioException catch (e) {
      logger.e('GET request failed: ${e.message}', error: e);
      throw e;
    }
  }

  @override
  Future<dynamic> callPostApiResponse({
    required String url,
    required dynamic body,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? myHeaders,
    Options? options, // Thêm tham số options
  }) async {
    try {
      final dio = await instance;
      final response = await dio.post(
        url,
        data: body,
        queryParameters: parameters,
        options: options ?? Options(headers: myHeaders), // Ưu tiên options nếu có
      );
      return response.data;
    } on DioException catch (e) {
      logger.e('POST request failed: ${e.message}', error: e);
      throw e;
    }
  }


  // Triển khai phương thức PUT
  @override
  Future<dynamic> callPutApiResponse({
    required String url,
    required dynamic body,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? myHeaders,
  }) async {
    try {
      final dio = await instance;
      final response = await dio.put(
        url,
        data: body,
        queryParameters: parameters,
        options: Options(headers: myHeaders),
      );
      return response.data;
    } on DioException catch (e) {
      throw e;
    }
  }

  // Triển khai phương thức DELETE
  @override
  Future<dynamic> callDeleteApiResponse({
    required String url,
    required dynamic body,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? myHeaders,
  }) async {
    try {
      final dio = await instance;
      final response = await dio.delete(
        url,
        data: body,
        queryParameters: parameters,
        options: Options(headers: myHeaders),
      );
      return response.data;
    } on DioException catch (e) {
      throw e;
    }
  }

}
