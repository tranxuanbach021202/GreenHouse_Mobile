import 'dart:io';
import 'package:dio/dio.dart';

class CloudStorageService {
  final Dio _dio = Dio();

  Future<bool> uploadFile({
    required String presignedUrl,
    required File file,
    required String contentType,
  }) async {
    try {
      final length = await file.length();
      final response = await _dio.put(
        presignedUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': length.toString(),
          },
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Upload failed: $e");
      return false;
    }
  }
}
