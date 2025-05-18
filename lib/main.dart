// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenhouse/screens/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:greenhouse/screens/invitations/viewmodel/invitation_view_model.dart';
import 'package:greenhouse/screens/onboarding/viewmodels/onboarding_view_model.dart';
import 'package:greenhouse/screens/otp_verify/viewmodel/otp_verify_view_model.dart';
import 'package:greenhouse/screens/project_creation/project_setup_provider.dart';
import 'package:greenhouse/screens/project_creation/viewmodel/criterion_view_model.dart';
import 'package:greenhouse/screens/project_creation/viewmodel/experiment_layout_view_model.dart';
import 'package:greenhouse/screens/project_creation/viewmodel/factors_levels_view_model.dart';
import 'package:greenhouse/screens/project_creation/viewmodel/general_info_view_model.dart';
import 'package:greenhouse/screens/project_creation/viewmodel/member_permissions_view_model.dart';
import 'package:greenhouse/screens/project_detail/viewmodel/project_detail_view_model.dart';
import 'package:greenhouse/screens/project_management/viewmodel/project_management_view_model.dart';
import 'package:greenhouse/screens/signin/viewmodel/signin_view_model.dart';
import 'package:greenhouse/screens/signup/viewmodel/signup_view_model.dart';
import 'package:greenhouse/screens/splash/viewmodel/splash_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'base/services/navigation_service.dart';
import 'base/services/notification_service.dart';
import 'core/router/app_router.dart';
import 'di/di.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // checkFirebase();
  // await NotificationService.initialize();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => getIt<SplashViewModel>()),
            ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
            ChangeNotifierProvider(create: (_) => getIt<SignUpViewModel>()),
            ChangeNotifierProvider(create: (_) => getIt<SignInViewModel>()),
            ChangeNotifierProvider(create: (_) => getIt<OtpVerifyViewModel>()),
            ChangeNotifierProvider(create: (_) => getIt<MemberPermissionsViewModel>()),
            ChangeNotifierProvider(create: (_) => getIt<FactorsLevelsViewModel>()),
            ChangeNotifierProvider(create: (_) => getIt<CriterionViewModel>()),
            ChangeNotifierProvider(create: (_) => getIt<ExperimentLayoutViewModel>()),
            ChangeNotifierProvider(create: (_) => getIt<ProjectSetupProvider>()),
            ChangeNotifierProvider(create: (_) => getIt<GeneralInfoViewModel>()),
            ChangeNotifierProvider(create: (_) => getIt<DashboardViewModel>()),
            ChangeNotifierProvider(create: (_) => getIt<InvitationViewModel>()..fetchInvitations()),
            ChangeNotifierProvider(create: (_) => getIt<ProjectManagementViewModel>()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            title: "GreenHouse",
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
          ),
        );
      },
    );
  }
}


// void checkFirebase() async {
//   await Firebase.initializeApp();
//   print("✅ Firebase đã được khởi tạo thành công!");
// }
//
//
// Future<void> getDeviceToken() async {
//   final fcm = FirebaseMessaging.instance;
//   final token = await fcm.getToken();
//   print("✅ Device token: $token");
// }

