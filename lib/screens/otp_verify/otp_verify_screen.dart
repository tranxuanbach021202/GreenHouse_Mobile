import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenhouse/base/views/widget/custom_button_widget.dart';
import 'package:greenhouse/core/app_images.dart';
import 'package:greenhouse/screens/otp_verify/viewmodel/otp_verify_view_model.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/logger.dart';
import 'otp_purpose.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  final OtpPurpose purpose;

  const OtpVerifyScreen({
    Key? key,
    required this.email,
    required this.purpose,
  }) : super(key: key);


  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
        (index) => FocusNode(),
  );
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OtpVerifyViewModel>().initialize(widget.email, widget.purpose);
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }


  String getOtpValue() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OtpVerifyViewModel>();
    logger.i("OTP Screen " + widget.email) ;
    return Scaffold(
      backgroundColor: AppColors.culTured,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // nav bar
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
                    'Nhập mã xác minh',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.stateGreen,
                    ),
                  )
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.center,
                child: Text(
                  textAlign: TextAlign.center,
                  'Vui lòng nhập mã xác minh đã gửi địa chỉ \n email của bạn ' + widget.email,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.black90,
                  ),
                ),
              ),
              SizedBox(height: 40.h),

              // 4 ô
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                      (index) => SizedBox(
                    width: 70,
                    height: 70,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 1,
                      style: const TextStyle(fontSize: 24),
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF004A3F),
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        viewModel.clearError();
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),
              if (viewModel.errorMessage != null) ...[
                SizedBox(height: 16.h),
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              SizedBox(height: 160.h),
              CustomButtonWidget(
                isLoading: viewModel.isLoading,
                onPressed: () => viewModel.verifyOtp(
                  getOtpValue(),
                  onFailed: clearOtpFields,
                ),
                text: "Xác nhận",
                loadingText: "Đang xác nhận",
                backgroundColor: AppColors.stateGreen,
              ),


              SizedBox(height: 40.h),


            ],
          ),
        ),
      ),
    );
  }
}
