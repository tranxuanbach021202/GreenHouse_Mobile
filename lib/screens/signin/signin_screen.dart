import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/core/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:greenhouse/screens/signin/viewmodel/signin_view_model.dart';
import 'package:provider/provider.dart';
import '../../../core/app_images.dart';
import '../../base/views/widget/custom_text_form_field_widget.dart';
import '../../base/views/widget/loading_overlay_widget.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return ChangeNotifierProvider.value(
      // Lấy instance của SignInViewModel từ GetIt
      value: GetIt.I<SignInViewModel>(),
      child: _SignInScreenContent(),
    );
  }
}

class _SignInScreenContent extends StatelessWidget {
  const _SignInScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignInViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LoadingOverlayWidget(
        isLoading: viewModel.isLoading,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.bg_spash),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Phần logo và nút back
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Image.asset(
                            AppImages.logo_greenhouse,
                            height: 100.h,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Spacer(flex: 2),


                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.whiteSmoke,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                    ),
                    padding: EdgeInsets.all(24.w),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chào mừng bạn\nđến với Green House',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.stateGreen,
                            ),
                          ),
                          SizedBox(height: 30.h),
                          CustomTextFormFieldWidget(
                            obscureText: false,
                            controller: viewModel.userController,
                            hintText: 'Tài khoản',
                            prefix: Icon(Icons.email, color: AppColors.culTured),
                            fillColor: AppColors.stateGreen,
                          ),
                          SizedBox(height: 16.h),
                          CustomTextFormFieldWidget(
                            controller: viewModel.passwordController,
                            hintText: 'Mật khẩu',
                            prefix: Icon(Icons.lock, color: AppColors.culTured),
                            suffix: GestureDetector(
                              onTap: viewModel.togglePasswordVisibility,
                              child: Icon(
                                viewModel.isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.culTured,
                              ),
                            ),
                            obscureText: !viewModel.isPasswordVisible,
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

                          SizedBox(height: 8.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                context.push("/forgot_password");
                              },
                              child: Text(
                                'Quên mật khẩu?',
                                style: TextStyle(color: AppColors.stateGreen),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: viewModel.signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.stateGreen,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Bạn chưa có tài khoản? '),
                              TextButton(
                                onPressed: () {
                                  context.push('/signup');
                                },
                                child: Text(
                                  'Đăng ký',
                                  style: TextStyle(
                                    color: AppColors.stateGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                        ],
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




