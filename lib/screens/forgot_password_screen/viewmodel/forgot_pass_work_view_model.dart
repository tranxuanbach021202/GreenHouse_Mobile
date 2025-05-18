import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/base/viewmodels/base_view_model.dart';
import 'package:greenhouse/respositories/auth_repository.dart';

import '../../../network_service/api_service.dart';
import '../../../network_service/app_exception.dart';
import '../../../utils/logger.dart';
import '../../otp_verify/otp_purpose.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  final emailController = TextEditingController();
  final AuthRepository _authRepository;

  ForgotPasswordViewModel({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;


  Future<void> submit(BuildContext context) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setError('Vui lòng email tài ');
      return;
    }

    isLoading = true;
    clearError();
    try {
      await _authRepository.forgotPassword(email);
      context.go('/otp_verify', extra: {
        'email': email,
        'purpose': OtpPurpose.forgotPassword,
      });

    } on ApiException catch (e) {
      logger.e("Lỗi API: ${e.message}");
      switch (e.type) {
        case ApiErrorType.userNotFound:
          setError('Tài khoản không tồn tại. Vui lòng kiểm tra lại.');
          break;
        default:
          setError('Đã có lỗi xảy ra. Vui lòng thử lại sau.');
          break;
      }
    } finally {
      isLoading = false;
    }
  }


  @override
  FutureOr<void> init() {
    // TODO: implement init
  }
}
