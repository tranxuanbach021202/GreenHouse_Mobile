import 'package:greenhouse/models/response/pagination.dart';

class ApiResponse<T> {
  final int code;
  final String message;
  final T data;
  final Pagination? meta;

  ApiResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
      ) {
    return ApiResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data: fromJsonT(json['data']),
      meta: json['meta'] == null
          ? null
          : Pagination.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'code': code,
      'message': message,
      'data': toJsonT(data),
      'meta': meta?.toJson(),
    };
  }
}


