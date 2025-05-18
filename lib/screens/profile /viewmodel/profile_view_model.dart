import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greenhouse/base/viewmodels/base_view_model.dart';
import 'package:greenhouse/respositories/auth_repository.dart';
import 'package:greenhouse/respositories/user_repository.dart';

import '../../../models/response/api_response.dart';
import '../../../models/user_model.dart';
import '../../../utils/logger.dart';

class ProfileViewModel extends BaseViewModel {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  User? _user;
  User? get user => _user;

  ProfileViewModel({required UserRepository userRepository, required AuthRepository authRepository})
      : _userRepository = userRepository,
        _authRepository = authRepository;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> fetchCurrentUserProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _userRepository.getUserProfile();
      final apiResponse = ApiResponse<User>.fromJson(
        response,
            (data) => User.fromJson(data as Map<String, dynamic>),
      );

      _user = apiResponse.data;
      _isInitialized = true;
    } catch (e) {
      logger.e("Lỗi khi lấy profile user: $e");
      setError("Không thể lấy thông tin người dùng.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> logout() async {
    try {
      isLoading = true;
      notifyListeners();

      await _authRepository.signout();
      _user = null;
      _isInitialized = false;

      notifyListeners();
    } catch (e) {
      logger.e("Lỗi khi đăng xuất: $e");
      setError("Không thể đăng xuất.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  FutureOr<void> init() async {
    await fetchCurrentUserProfile();
  }
}
