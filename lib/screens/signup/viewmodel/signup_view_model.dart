import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../base/services/navigation_service.dart';
import '../../../base/services/storage_service.dart';
import '../../../base/viewmodels/base_view_model.dart';
import '../../../core/router/app_router.dart';
import '../../../network_service/app_exception.dart';
import '../../../respositories/auth_repository.dart';
import '../../../utils/logger.dart';
import '../../otp_verify/otp_purpose.dart';

class SignUpViewModel extends BaseViewModel {
  final AuthRepository _authRepository;
  final NavigationService _navigationService;
  final StorageService _storageService;

  // Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // UI States
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;


  SignUpViewModel({
    required AuthRepository authRepository,
    required NavigationService navigationService,
    required StorageService storageService,
  })  : _authRepository = authRepository,
        _navigationService = navigationService,
        _storageService = storageService;

  @override
  FutureOr<void> init() async {
    // Khởi tạo các giá trị ban đầu
    _isPasswordVisible = false;

    // Có thể thêm các logic khởi tạo khác ở đây nếu cần
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    reloadState();
  }

  bool _validateInputs() {
    clearError();

    if(usernameController.text.isEmpty && emailController.text.isEmpty
        && passwordController.text.isEmpty) {
      setError('Vui lòng nhập đầy đủ thông tin');
      return false;
    }
    if (usernameController.text.isEmpty) {
      setError('Vui lòng nhập tên đăng nhập');
      return false;
    }

    if (emailController.text.isEmpty) {
      setError('Vui lòng nhập email');
      return false;
    }

    if (!_isValidEmail(emailController.text)) {
      setError('Email không hợp lệ');
      return false;
    }

    if (passwordController.text.isEmpty) {
      setError('Vui lòng nhập mật khẩu');
      return false;
    }

    if (passwordController.text.length < 6) {
      setError('Mật khẩu phải có ít nhất 6 ký tự');
      return false;
    }

    if (confirmPasswordController.text.isEmpty) {
      setError('Vui lòng nhập lại mật khẩu');
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setError('Mật khẩu nhập lại không khớp');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> signup() async {
    if (!_validateInputs()) {
      logger.w("Validation failed");
      return;
    }
    clearError();

    logger.i("SIGNUP test");
    try {
      isLoading = true;

      final response = await _authRepository.signup(
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
        roles: ["USER"],
      );

      logger.i("SIGNUP success await");
      if (response != null) {
        logger.i("Đăng ký thành công: ${response.toString()}");
        _navigationService.push('/otp_verify', extra: {
          'email': emailController.text,
          'purpose': OtpPurpose.register,
        });
      }
    } on ApiException catch (e) {
      switch (e.type) {
        case ApiErrorType.accountExist:
          setError('Tài khoản đã tồn tại. Vui lòng kiểm tra lại.');
          break;
        case ApiErrorType.duplicateEmail:
          setError('Email đã tồn tại. Vui lòng kiểm tra lại.');
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
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
