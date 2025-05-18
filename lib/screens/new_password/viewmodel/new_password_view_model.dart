

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../base/services/navigation_service.dart';
import '../../../base/viewmodels/base_view_model.dart';
import '../../../core/colors.dart';
import '../../../respositories/auth_repository.dart';

class NewPasswordViewModel extends BaseViewModel {
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final NavigationService _navigationService = GetIt.I<NavigationService>();

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  FutureOr<void> init() {}

  Future<void> resetPassword({
    required BuildContext context,
    required String resetToken,
    required String email,
  }) async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setError('Vui lòng nhập đầy đủ mật khẩu mới và xác nhận.');
      return;
    }

    if (newPassword != confirmPassword) {
      setError('Mật khẩu xác nhận không khớp.');
      return;
    }

    isLoading = true;
    clearError();

    try {
      await _authRepository.resetPassword(resetToken, newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Đổi mật khẩu thành công!',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          backgroundColor: AppColors.stateGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150,
            left: 20,
            right: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      _navigationService.go('/signin');
    } catch (e) {
      setError("Đổi mật khẩu thất bại. Vui lòng thử lại.");
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}