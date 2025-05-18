import 'package:dio/dio.dart';
import 'package:greenhouse/network_service/network_url/app_network_urls.dart';
import 'package:logger/logger.dart';
import '../models/response/auth_response.dart';
import '../network_service/api_service.dart';
import '../network_service/app_exception.dart';

class AuthRepository {
  final ApiService _apiService;
  final logger = Logger();

  AuthRepository(this._apiService);
  Future<dynamic> signin(String user, String password) async {
    try {
      logger.i("Signin viewmodel bat dau login");
      final response = await _apiService.callPostApiResponse(
        url: AppNetworkUrls.signin,
        body: {
          'username': user,
          'password': password,
        },
      );
      logger.i("Signin viewmodel login thanh cong");
      return response;
    } on DioException catch (e) {
      logger.e("Error auth signin \n" + e.toString());
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }

  Future<dynamic> signup({
    required String username,
    required String email,
    required String password,
    required List<String> roles
  }) async {
    try {
      final response = await _apiService.callPostApiResponse(
        url: '/auth/signup',
        body: {
          'username': username,
          'email': email,
          'password': password,
          'roles': roles,
        },
      );
      logger.i("SIGNUP test repository");
      return response;
    } on DioException catch (e) {
      logger.e("Error auth signup \n"  + e.toString());
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      logger.i("📨 Bắt đầu gửi yêu cầu quên mật khẩu với email: $email");

      await _apiService.callPostApiResponse(
        url: AppNetworkUrls.forgotPassword,
        body: {
          'email': email,
        },
      );

      logger.i("✅ Gửi OTP quên mật khẩu thành công.");
    } on DioException catch (e) {
      logger.e("❌ Lỗi khi gửi OTP quên mật khẩu: ${e.message}");
      throw ApiException.fromDioError(e);
    }
  }


  Future<String?> verifyOtpForForgotPassword(String email, String otp) async {
    try {
      final response = await _apiService.callPostApiResponse(
        url: AppNetworkUrls.verifyOtpForgotPass,
        body: {
          'email': email,
          'otp': otp,
        },
      );

      if (response != null && response['resetToken'] != null) {
        return response['resetToken'] as String;
      }

      throw ApiException(message: 'Không tìm thấy resetToken trong phản hồi');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }


  Future<void> resetPassword(String resetToken, String newPassword) async {
    try {
      final body = {
        'resetToken': resetToken,
        'newPassword': newPassword,
      };

      final response = await _apiService.callPostApiResponse(
        url: '/auth/reset-password',
        body: body,
      );

      logger.i("Reset password thành công: $response");
    } on DioException catch (e) {
      logger.e("Lỗi khi reset password: ${e.toString()}");
      rethrow;
    }
  }



  Future<void> signout() async {
    try {
      await _apiService.callPostApiResponse(
        url: '/auth/logout',
        body: {},
      );
    } catch (e) {
      // Có thể bỏ qua lỗi logout API
      print('Logout API error: $e');
    }
  }


  Future<dynamic> verifyOtp(String email, String otpCode)  async {
    try {
      final response = await _apiService.callPostApiResponse(
        url: '/auth/verify-otp',
        body: {
          'email': email,
          'otp': otpCode
        },
      );
      logger.i("OTPVERIFY test repository");
      return response;
    } on DioException catch (e) {
      logger.e("Error auth signup \n"  + e.toString());
      throw ApiException.fromDioError(e);
    }

  }



  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _apiService.callPostApiResponse(
        url: '/auth/refresh-token',
        body: {'refreshToken': refreshToken},
      );

      return AuthResponse.fromJson(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }


  Future<void> logout() async {
    try {
      await _apiService.callPostApiResponse(
        url: AppNetworkUrls.logout,
        body: {},
      );
    } catch (e) {
      // Có thể bỏ qua lỗi logout API
      print('Logout API error: $e');
    }
  }
}

