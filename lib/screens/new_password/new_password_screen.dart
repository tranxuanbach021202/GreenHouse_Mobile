import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/screens/new_password/viewmodel/new_password_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../base/views/widget/custom_text_form_field_widget.dart';
import '../../base/views/widget/custom_button_widget.dart';
import '../../base/views/widget/loading_overlay_widget.dart';
import '../../core/app_images.dart';
import '../../core/colors.dart';
import '../../utils/logger.dart';

class NewPasswordScreen extends StatelessWidget {
  final String resetToken;
  final String email;

  const NewPasswordScreen({
    Key? key,
    required this.resetToken,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewPasswordViewModel(),
      child: _ResetPasswordScreenContent(
        resetToken: resetToken,
        email: email,
      ),
    );
  }
}

class _ResetPasswordScreenContent extends StatelessWidget {
  final String resetToken;
  final String email;

  const _ResetPasswordScreenContent({
    required this.resetToken,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NewPasswordViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LoadingOverlayWidget(
        isLoading: vm.isLoading,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.stateGreen,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    Image.asset(AppImages.logo_greenhouse, width: 50.w, height: 50.h),
                  ],
                ),

                SizedBox(height: 30.h),

                // Tiêu đề
                Center(
                  child: Text(
                    'Đổi mật khẩu',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF004A1E),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: Text(
                    'Hãy nhập mật khẩu mới của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                  ),
                ),

                SizedBox(height: 40.h),

                CustomTextFormFieldWidget(
                  controller: vm.newPasswordController,
                  hintText: 'Mật khẩu mới',
                  prefix: Icon(Icons.lock, color: AppColors.culTured),
                  suffix: Icon(Icons.visibility, color: AppColors.culTured),
                  obscureText: true,
                  fillColor: AppColors.stateGreen,
                ),


                SizedBox(height: 20,),

                CustomTextFormFieldWidget(
                  controller: vm.confirmPasswordController,
                  hintText: 'Xác nhận mật khẩu mới',
                  prefix: Icon(Icons.lock, color: AppColors.culTured),
                  suffix: Icon(Icons.visibility, color: AppColors.culTured),
                  obscureText: true,
                  fillColor: AppColors.stateGreen,
                ),

                if (vm.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: 16.h, left: 8.w),
                    child: Text(
                      vm.errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  ),

                SizedBox(height: 40.h),

                Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => {vm.resetPassword(context: context,resetToken: resetToken, email: email)},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.stateGreen,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Tiếp tục',
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
          ),
        ),
      ),
    );
  }
}
