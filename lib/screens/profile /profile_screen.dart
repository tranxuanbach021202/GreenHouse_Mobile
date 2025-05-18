import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/screens/profile%20/viewmodel/profile_view_model.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/app_images.dart';
import '../../di/di.dart';
import 'edit_profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProfileViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (!viewModel.isInitialized) {
            return Center(
              child: Lottie.asset(
                AppImages.loadding,
                width: 160,
                height: 160,
              ),
            );
          }
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.bg_spash),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  // Profile Section
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(

                          onTap: () async {
                            final result = await context.push('/edit_profile', extra: _viewModel.user);
                            if (result == true) {
                              viewModel.fetchCurrentUserProfile();
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: ClipOval(
                                  child: FadeInImage.assetNetwork(
                                    placeholder: AppImages.defaultAvatar,
                                    image: _viewModel.user?.urlAvatar ?? '',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.white,
                                        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 16,
                                  child: Icon(Icons.edit, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          viewModel.user!.username,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu Section với bo góc
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                      ),
                      padding: EdgeInsets.all(24.w),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildOption(Icons.person_pin, "Về tôi"),
                            _buildOption(Icons.settings, "Cài đặt"),
                            _buildOption(Icons.language, "Ngôn ngữ"),
                            _buildOption(Icons.info, "Giới thiệu về các dự án"),
                            SizedBox(height: 24.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await viewModel.logout();
                                  context.go('/signin');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF003D1F),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'Đăng xuất',
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOption(IconData icon, String title) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: Colors.green),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.green[900],
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }

}
