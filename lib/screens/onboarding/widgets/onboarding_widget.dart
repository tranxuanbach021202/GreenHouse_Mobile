import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/colors.dart';
import '../onboarding_item.dart';

class OnboardingWidget extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingWidget({
    Key? key,
    required this.item,
  }) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(item.image, height: 200),
          SizedBox(height: 30,),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.stateGreen,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.black90,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
