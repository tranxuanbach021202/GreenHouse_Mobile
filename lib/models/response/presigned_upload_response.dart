class PresignedUploadResponse {
  final String presignedUrl;
  final String objectKey;
  final int expirationTime;

  PresignedUploadResponse({
    required this.presignedUrl,
    required this.objectKey,
    required this.expirationTime,
  });

  factory PresignedUploadResponse.fromJson(Map<String, dynamic> json) {
    return PresignedUploadResponse(
      presignedUrl: json['presignedUrl'],
      objectKey: json['objectKey'],
      expirationTime: json['expirationTime'],
    );
  }
}
