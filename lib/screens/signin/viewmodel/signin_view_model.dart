import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:greenhouse/respositories/device_token_repository.dart';
import '../../../base/services/navigation_service.dart';
import '../../../base/services/storage_service.dart';
import '../../../base/viewmodels/base_view_model.dart';
import '../../../core/router/app_router.dart';
import '../../../models/request/device_token_request.dart';
import '../../../models/response/auth_response.dart';
import '../../../network_service/app_exception.dart';
import '../../../respositories/auth_repository.dart';
import '../../../utils/logger.dart';

class SignInViewModel extends BaseViewModel {
  final NavigationService _navigationService;
  final StorageService _storageService;
  final AuthRepository _authRepository;
  final DeviceTokenRepository _deviceTokenRepository;
  

  // Controllers
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // UI States
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  // Constructor
  SignInViewModel({
    required AuthRepository authRepository,
    required NavigationService navigationService,
    required StorageService storageService,
    required DeviceTokenRepository deviceTokenRepository
  })  : _authRepository = authRepository,
        _navigationService = navigationService,
        _storageService = storageService,
        _deviceTokenRepository = deviceTokenRepository;

  @override
  FutureOr<void> init() async {
    _isPasswordVisible = false;
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    reloadState();
  }



  bool _validateInputs() {
    clearError();
    bool isValid = true;

    if(userController.text.isEmpty && passwordController.text.isEmpty) {
      setError('Vui lòng nhập đầy đủ thông tin đăng nhập.');
      isValid = false;
    } else if (userController.text.isEmpty) {
      setError('Vui lòng nhập tên đăng nhập.');
      isValid = false;
    } else if (passwordController.text.isEmpty) {
      setError('Vui lòng nhập mật khẩu.');
      isValid = false;
    }
    return isValid;
  }

  Future<void> signIn() async {
    if (!_validateInputs()) {
      logger.w("Validation failed");
      return;
    }
    clearError();
    try {
      isLoading = true;

      final response = await _authRepository.signin(
          userController.text,
          passwordController.text,
        );
      final authResponse = AuthResponse.fromJson(response);
      await Future.delayed(const Duration(seconds: 1));
      if (authResponse != null) {
        logger.i("Đăng nhập thành công");
        await _storageService.saveAuthData(authResponse);
        await syncTokenDevice();
        _navigationService.go('/main_screen');
      }
    } on ApiException catch (e) {
      logger.e("Lỗi API: ${e.message}");
      switch (e.type) {
        case ApiErrorType.wrongPassword:
          setError('Sai mật khẩu. Vui lòng kiểm tra lại.');
          break;
        case ApiErrorType.userNotFound:
          setError('Tài khoản không tồn tại. Vui lòng kiểm tra lại.');
          break;
        default:
          setError('Đã có lỗi xảy ra. Vui lòng thử lại sau.');
          break;
      }
    } finally {
      isLoading = false; // Sử dụng setter từ BaseViewModel
    }
  }

  Future<void> syncTokenDevice() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        final request = DeviceTokenRequest(
          token: token,
          platform: Platform.isAndroid ? "android" : "ios",
        );
        await _deviceTokenRepository.syncDeviceToken(request);
        debugPrint("✅ Token synced: $token");
      }
    } catch (e) {
      debugPrint("❌ Failed to sync token: $e");
    }
  }


  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
