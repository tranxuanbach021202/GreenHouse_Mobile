class AppNetworkUrls {

  // http://10.0.2.2:8088/api/v1

  // http://14.225.212.50:8088/api/v1

  static const String baseUrl = 'http://10.0.2.2:8088/api/v1';

  static const String signup = '/auth/signup';

  static const String logout = '/auth/logout';

  static const String verifyOtp = '/auth/verify-otp';

  static const String verifyOtpForgotPass = '/auth/verify-otp-forgot-password';

  static const String resetPassword = '/auth/reset-password';

  static const String signin = '/auth/signin';

  static const String forgotPassword = '/auth/forgot-password';

  static const String users = '/users';

  static const String updateProfile = '/users/profile';

  static const String createProject = '/project/add';

  static const String getProjectUser = '/project/list';

  static const String uploadUrl = '/storage/upload-url';

  static const String project = '/project';


  static const String measurement = '/measurement';

  static const String exQrCode = '/project/generate/qr';

  static const String device_token = '/fcm/device-token';

  static const String invitations = '/invitations';
}