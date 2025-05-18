import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';

import '../utils/logger.dart';

enum ApiErrorType {
  userNotFound,         // Tài khoản không tồn tại
  wrongPassword,        // Sai mật khẩu
  networkError,         // Lỗi mạng
  serverError,         // Lỗi server
  tokenExpired,       // Token hết hạn
  invalidToken,      // Token không hợp lệ
  unauthorized,     // Không có quyền truy cập
  unknown,        // Lỗi không xác định
  storageError,  // Lỗi lưu trữ local
  validationError, // Lỗi validation
  businessError,  // Lỗi nghiệp vụ
  accountExist,  // Tài khoản đã tồn tại
  duplicateEmail, // Email đã tồn tại
  duplicateProjectCode, // Mã dự án đã tồn tại
  wrongOtp,
}

class ApiException implements Exception {
  final String code; // Mã lỗi từ backend
  final String title; // Tiêu đề lỗi (nếu có)
  final String message; // Thông báo lỗi chi tiết
  final int? statusCode; // HTTP Status Code (nếu có)
  final ApiErrorType type; // Loại lỗi (network, backend, etc.)

  ApiException({
    required this.message,
    this.code = 'UNKNOWN',
    this.title = 'Unknown Error',
    this.statusCode,
    this.type = ApiErrorType.unknown,
  });

  factory ApiException.fromBackend(Map<String, dynamic> response, [int? statusCode]) {
    return ApiException(
      code: response['code'] ?? 'UNKNOWN',
      title: response['title'] ?? 'Unknown Error',
      message: response['message'] ?? 'An unknown error occurred',
      statusCode: statusCode,
      type: _mapBackendCodeToErrorType(response['code']),
    );
  }

  factory ApiException.fromDioError(DioException error) {
    try {
      final data = error.response?.data;
      final parsed = data is String ? jsonDecode(data) : data;

      return ApiException(
        message: parsed['message'] ?? 'Lỗi không xác định',
        title: parsed['title'] ?? '',
        code: parsed['code'] ?? 'UNKNOWN',
        type: _mapBackendCodeToErrorType(parsed['code']),
      );
    } catch (e) {
      return ApiException(
        message: error.message ?? 'Lỗi không xác định',
        type: ApiErrorType.unknown,
      );
    }
  }

  static ApiException _handleNetworkError(DioException error) {
    String message;
    ApiErrorType type;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Không thể kết nối đến server, vui lòng thử lại';
        type = ApiErrorType.networkError;
        break;

      default:
        if (error.error is SocketException) {
          message = 'Không có kết nối internet, vui lòng kiểm tra mạng';
          type = ApiErrorType.networkError;
        } else {
          message = 'Đã xảy ra lỗi không xác định';
          type = ApiErrorType.unknown;
        }
    }

    return ApiException(
      message: message,
      type: type,
    );
  }

  /// Map mã lỗi từ backend sang `ApiErrorType`
  static ApiErrorType _mapBackendCodeToErrorType(String? code) {
    switch (code) {
      case '44': // ko tồn tại user
        return ApiErrorType.userNotFound;
      case '1': // Sai mật khẩu
        return ApiErrorType.wrongPassword;
      case '2': // Token hết hạn
        return ApiErrorType.tokenExpired;
      case '3': // Token không hợp lệ
        return ApiErrorType.invalidToken;
      case '4': // Không có quyền truy cập
        return ApiErrorType.unauthorized;
      case '5': // Tài khoản tồn tại
        return ApiErrorType.accountExist;
      case '6': // Tài khoản tồn tại
        return ApiErrorType.duplicateEmail;
      case '45': // Mã dự án đã tồn tại
        return ApiErrorType.duplicateProjectCode;
      case '7': // Mã dự án đã tồn tại
        return ApiErrorType.wrongOtp;
      default:
        return ApiErrorType.unknown;
    }
  }

  @override
  String toString() {
    return 'ApiException: $title - $message (code: $code, status: $statusCode)';
  }
}
