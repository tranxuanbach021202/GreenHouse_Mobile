import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/core/app_images.dart';
import 'package:greenhouse/core/strings.dart';
import '../../../base/services/localization_service.dart';
import '../../../base/services/storage_service.dart';
import '../../../di/di.dart';
import '../onboarding_item.dart';

class OnboardingViewModel extends ChangeNotifier {
  final _storageService = getIt<StorageService>();
  int _currentPage = 0;
  final int _totalPages = 3;

  int get currentPage => _currentPage;

  bool get isLastPage => _currentPage == _totalPages -1;

  final PageController pageController = PageController();


  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  Future<void> completeIntro() async {

  }
  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
        title: AppStrings.title_intro1,
        description: AppStrings.description1,
        image: AppImages.intro1),
    OnboardingItem(
        title: AppStrings.title_intro2,
        description: AppStrings.description2,
        image: AppImages.intro2),
    OnboardingItem(
        title: AppStrings.title_intro3,
        description: AppStrings.description3,
        image: AppImages.intro3),
  ];


  Future<void> onNextPressed(BuildContext context) async {
    if (isLastPage) {
      await _storageService.setIntroSeen(true);
      context.go('/signin');
    } else {
      _currentPage++;
      pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }



}

