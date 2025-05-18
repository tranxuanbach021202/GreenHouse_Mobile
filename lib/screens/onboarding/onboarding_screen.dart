import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenhouse/core/colors.dart';
import 'package:greenhouse/screens/onboarding/onboarding_item.dart';
import 'package:greenhouse/screens/onboarding/viewmodels/onboarding_view_model.dart';
import 'package:greenhouse/screens/onboarding/widgets/onboarding_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingScreen extends StatelessWidget {
  final PageController _pageController = PageController();

  OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.whiteSmoke,
            body: Stack(
              children: [
                PageView.builder(
                  controller: viewModel.pageController,
                  onPageChanged: viewModel.setCurrentPage,
                  itemCount: viewModel.onboardingItems.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.onboardingItems[index];
                    return OnboardingWidget(item: item);
                  },
                ),

                // Dots
                Positioned(
                  bottom: 180,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      viewModel.onboardingItems.length,
                          (index) => buildDot(
                        context: context,
                        index: index,
                        currentPage: viewModel.currentPage,
                      ),
                    ),
                  ),
                ),

                // Button
                Positioned(
                  bottom: 70,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () => context.read<OnboardingViewModel>().onNextPressed(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.stateGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      viewModel.isLastPage ? 'Get Started' : 'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildDot({
    required BuildContext context,
    required int index,
    required int currentPage,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: currentPage == index ? AppColors.stateGreen : AppColors.greyCloud,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}



