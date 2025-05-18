import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final bool isTextButton;
  final bool isLoading;
  final String? loadingText;

  const CustomButtonWidget({
    Key? key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.isTextButton = false,
    this.isLoading = false,
    this.loadingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String displayLoadingText = loadingText ?? "Đang xử lý...";

    if (isTextButton) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              displayLoadingText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          ],
        )
            : Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        disabledBackgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        minimumSize: Size(double.infinity, 48.sp),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: isLoading
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            displayLoadingText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
            ),
          ),
        ],
      )
          : Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

  }
}


