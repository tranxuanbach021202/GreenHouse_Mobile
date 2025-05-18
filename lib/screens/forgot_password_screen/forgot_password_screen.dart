import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/screens/forgot_password_screen/viewmodel/forgot_pass_work_view_model.dart';
import 'package:provider/provider.dart';

import '../../base/views/widget/custom_text_form_field_widget.dart';
import '../../base/views/widget/loading_overlay_widget.dart';
import '../../core/app_images.dart';
import '../../core/colors.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});



  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return ChangeNotifierProvider.value(
      value: GetIt.I<ForgotPasswordViewModel>(),
      child: const _ForgotPasswordContent(),
    );
  }
}

class _ForgotPasswordContent extends StatelessWidget {
  const _ForgotPasswordContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();

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
                    'Quên mật khẩu?',
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
                    'Nhập tài khoản để nhận mã xác thực qua email',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                  ),
                ),

                SizedBox(height: 40.h),

                CustomTextFormFieldWidget(
                  controller: vm.emailController,
                  hintText: 'Nhập email tài khoản của bạn',
                  obscureText: false,
                  prefix: Icon(Icons.account_circle_outlined, color: AppColors.culTured),
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

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => vm.submit(context),
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
