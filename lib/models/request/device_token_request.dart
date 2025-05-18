class DeviceTokenRequest {
  final String token;
  final String platform;

  DeviceTokenRequest({required this.token, required this.platform});

  Map<String, dynamic> toJson() => {
    "token": token,
    "platform": platform,
  };
}
