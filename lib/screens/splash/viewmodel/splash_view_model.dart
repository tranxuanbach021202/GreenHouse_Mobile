
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../base/services/storage_service.dart';
import '../../../core/router/app_router.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  final StorageService _storageService;
  SplashViewModel(this._storageService);

  void testNavigateToQrScreen(BuildContext context) async {
    // context.go('/click_scan');

  }


  Future<void> checkFirstTime(BuildContext context) async {
    try {
      final isIntroSeen = await _storageService.isIntroSeen();

      await Future.delayed(const Duration(milliseconds: 500)); // hiệu ứng splash

      if (isIntroSeen) {
        context.go('/signin');
      } else {
        context.go('/onboarding');
      }
    } catch (e) {
      print('Error checking intro screen: $e');
      context.go('/signin'); // fallback
    }
  }


  Future<void> checkLogin(BuildContext context) async {
    final hasToken = _storageService.getToken() != null;

    await Future.delayed(const Duration(milliseconds: 500));

    if (hasToken) {
      context.go('/main_screen');
    } else {
      context.go('/signin');
    }
  }


}