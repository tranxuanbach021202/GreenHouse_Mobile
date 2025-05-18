import 'dart:async';

import 'package:flutter/material.dart';
import '../../../base/services/navigation_service.dart';
import '../../../base/viewmodels/base_view_model.dart';
import '../../../core/router/app_router.dart';
import '../../../network_service/app_exception.dart';
import '../../../respositories/auth_repository.dart';
import '../../../utils/logger.dart';
import '../otp_purpose.dart';


class OtpVerifyViewModel extends BaseViewModel {
  final AuthRepository _authRepository;
  final NavigationService _navigationService;


  late OtpPurpose purpose;

  String _email = '';
  String _otp = '';
  final formKey = GlobalKey<FormState>();

  // Getters
  String get email => _email;
  String get otp => _otp;

  OtpVerifyViewModel({
    required AuthRepository authRepository,
    required NavigationService navigationService,
  })  : _authRepository = authRepository,
        _navigationService = navigationService;

  @override
  FutureOr<void> init() async {
    clearError();
  }

  void initialize(String email, OtpPurpose otpPurpose) {
    _email = email;
    purpose = otpPurpose;
    reloadState();
  }

  void setOtp(String value) {
    _otp = value;
    reloadState();
  }

  bool validateOtp(String otpCode) {
    if (otpCode.isEmpty) {
      setError('Vui lòng nhập mã OTP');
      return false;
    }

    if (otpCode.length != 4) { // Đổi thành 4 vì UI có 4 ô input
      setError('Mã OTP phải có 4 ký tự');
      return false;
    }

    return true;
  }

  Future<void> verifyOtp(String otpCode, {VoidCallback? onFailed}) async {
    if (_email == null || otpCode.isEmpty) {
      setError("Thiếu thông tin để xác thực.");
      onFailed?.call();
      return;
    }

    if (!validateOtp(otpCode)) return;

    isLoading = true;
    clearError();

    try {
      logger.i("🔐 Đang xác thực OTP cho email: $_email với mục đích: $purpose");

      if (purpose == OtpPurpose.register) {
        await _authRepository.verifyOtp(_email!, otpCode);
        _navigationService.go('/success');
      } else if (purpose == OtpPurpose.forgotPassword) {
        final resetToken = await _authRepository.verifyOtpForForgotPassword(_email!, otpCode);
        _navigationService.push('/reset-password', extra: {
          'resetToken': resetToken,
          'email': _email,
        });
      }
    } on ApiException catch (e) {
      handleApiError(e);
      onFailed?.call();
    } catch (e) {
      logger.e("❌ Lỗi không xác định khi xác thực OTP: $e");
      setError("Đã xảy ra lỗi, vui lòng thử lại sau.");
      onFailed?.call();
    } finally {
      isLoading = false;
    }
  }



  void handleApiError(ApiException e) {
    switch (e.type) {
      case ApiErrorType.wrongOtp:
        setError('Mã OTP không chính xác. Vui lòng kiểm tra lại.');
        break;
      default:
        setError('Đã có lỗi xảy ra. Vui lòng thử lại sau.');
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}


