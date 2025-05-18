import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/core/app_images.dart';
import 'package:greenhouse/screens/signup/viewmodel/signup_view_model.dart';
import 'package:provider/provider.dart';

import '../../base/views/widget/custom_text_form_field_widget.dart';
import '../../base/views/widget/loading_overlay_widget.dart';
import '../../core/colors.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return ChangeNotifierProvider.value(
      value: GetIt.I<SignUpViewModel>(),
      child: _SignUpScreenContent(),
    );
  }
}

class _SignUpScreenContent extends StatelessWidget {

  const _SignUpScreenContent({Key? key}) : super(key: key);




  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LoadingOverlayWidget(
        isLoading: viewModel.isLoading,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
              color: AppColors.culTured
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header với nút back và logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF004A1E),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                        Image.asset(
                          AppImages.logo_greenhouse,
                          width: 50.w,
                          height: 50.h,
                        ),
                      ],
                    ),

                    SizedBox(height: 30.h),

                    // Tiêu đề và subtitle
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Xin chào!',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF004A1E),
                          ),
                        )
                    ),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        textAlign: TextAlign.center,
                        'Hãy cùng phát triển cộng đồng\nnghiên cứu cây trồng với chúng tôi',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Form đăng ký
                    CustomTextFormFieldWidget(
                      controller: viewModel.usernameController,
                      hintText: 'Tên tài khoản',
                      obscureText: false,
                      prefix: Icon(Icons.account_circle_outlined, color: AppColors.culTured),
                      fillColor: AppColors.stateGreen,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextFormFieldWidget(
                      controller: viewModel.emailController,
                      hintText: 'Email',
                      obscureText: false,
                      prefix: Icon(Icons.email, color: AppColors.culTured),
                      fillColor: AppColors.stateGreen,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextFormFieldWidget(
                      controller: viewModel.passwordController,
                      hintText: 'Mật khẩu',
                      prefix: Icon(Icons.lock, color: AppColors.culTured),
                      suffix: Icon(Icons.visibility, color: AppColors.culTured),
                      obscureText: true,
                      fillColor: AppColors.stateGreen,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextFormFieldWidget(
                      controller: viewModel.confirmPasswordController,
                      hintText: 'Xác nhận mật khẩu',
                      prefix: Icon(Icons.lock, color: AppColors.culTured),
                      suffix: Icon(Icons.visibility, color: AppColors.culTured),
                      obscureText: true,
                      fillColor: AppColors.stateGreen,
                    ),

                    if (viewModel.errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(top: 16.h, left: 8.w),
                        child: Text(
                          viewModel.errorMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),

                    SizedBox(height: 40.h),

                    // Nút đăng ký
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.stateGreen,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Đăng ký',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Link đăng nhập
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Bạn đã có tài khoản? '),
                        TextButton(
                          onPressed: () {
                            context.go('/signin');
                          },
                          child: Text(
                            'Đăng nhập',
                            style: TextStyle(
                              color: AppColors.stateGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30.h),

                    // Social login buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SocialLoginButton(
                          icon: AppImages.iconFacebook,
                          onPressed: () {},
                        ),
                        SizedBox(width: 20.w),
                        SocialLoginButton(
                          icon: AppImages.iconGoogle,
                          onPressed: () {},
                        ),
                        SizedBox(width: 20.w),
                        SocialLoginButton(
                          icon: AppImages.iconApple,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    // Thêm padding bottom để tránh bàn phím che content
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class SocialLoginButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;

  const SocialLoginButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Image.asset(
        icon,
        width: 40.w,
        height: 40.h,
      ),
    );
  }
}
