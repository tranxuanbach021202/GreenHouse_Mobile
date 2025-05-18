import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/models/response/project_response.dart';
import 'package:greenhouse/screens/click_scan_screen.dart';
import 'package:greenhouse/screens/dashboard/dashboard_screen.dart';
import 'package:greenhouse/screens/forgot_password_screen/forgot_password_screen.dart';
import 'package:greenhouse/screens/onboarding/onboarding_screen.dart';
import 'package:greenhouse/screens/profile%20/profile_screen.dart';
import 'package:greenhouse/screens/project_creation/screen/criterion_screen.dart';
import 'package:greenhouse/screens/project_creation/screen/experiment_layout_screen.dart';
import 'package:greenhouse/screens/project_creation/screen/factors_levels_screen.dart';
import 'package:greenhouse/screens/project_creation/screen/general_info_screen.dart';
import 'package:greenhouse/screens/project_creation/screen/member_permissions_screen.dart';
import 'package:greenhouse/screens/project_detail/measurement/screen/measurement_detail_screen.dart';
import 'package:greenhouse/screens/project_detail/project_detail_screen.dart';
import 'package:greenhouse/screens/project_detail/test_screen.dart';
import 'package:greenhouse/screens/project_management/project_management_screen.dart';
import 'package:greenhouse/screens/signin/signin_screen.dart';
import 'package:greenhouse/screens/signup/signup_screen.dart';
import 'package:greenhouse/screens/otp_verify/otp_verify_screen.dart';
import 'package:greenhouse/screens/home_screen/home_screen.dart';
import 'package:greenhouse/screens/main_screen.dart';
import 'package:greenhouse/screens/splash/splash_screen.dart';
import 'package:greenhouse/screens/success_screen.dart';
import 'package:greenhouse/base/views/widget/custom_success_screen.dart';
import 'package:greenhouse/base/services/success_screen_args.dart';

import '../../base/services/navigation_service.dart';
import '../../di/di.dart';
import '../../models/project_member.dart';
import '../../models/response/criterion_response.dart';
import '../../models/response/factor_response.dart';
import '../../models/user_model.dart';
import '../../screens/new_password/new_password_screen.dart';
import '../../screens/profile /edit_profile/edit_profile_screen.dart';
import '../../screens/project_detail/measurement/screen/add_measurement_screen.dart';
import '../../screens/qr_scan_screen.dart';
import '../../utils/logger.dart';
import 'arguments/data_transfer/add_measurement_args.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  navigatorKey: getIt<NavigationService>().navigationKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),


    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingScreen(),
    ),
    GoRoute(
      path: '/signin',
      builder: (context, state) => SignInScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignUpScreen(),
    ),
    GoRoute(
      path: '/member_permissions_project',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        final bool isEditMode = extra?['isEditMode'] ?? false;
        final String projectId = extra?['projectId'] ?? '';
        final List<ProjectMember> projectMembers = extra?['members'] ?? [];

        return MemberPermissionsScreen(
          isEditMode: isEditMode,
          members: projectMembers,
          projectId: projectId,
        );
      },
    ),

    GoRoute(
      path: '/edit_profile',
      builder: (context, state) {
        final user = state.extra as User;
        return EditProfileScreen(user: user);
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) {
        return OnboardingScreen();
      },
    ),
    GoRoute(
      path: '/member_permissions_project',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        final bool isEditMode = extra?['isEditMode'] ?? false;
        final List<ProjectMember> projectMembers = extra?['projectMembers'] ?? [];

        return MemberPermissionsScreen(
          isEditMode: isEditMode,
          members: projectMembers,
        );
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => DashboardScreen(),
    ),
    GoRoute(
      path: '/main_screen',
      builder: (context, state) => MainScreen(),
    ),
    GoRoute(
      path: '/measurement_detail/:id',
      name: 'measurement-detail',
      builder: (context, state) {
        final project = state.extra as ProjectResponse;
        final measurementId = state.pathParameters['id']!;
        return MeasurementDetailScreen.fromMeasurement(
          project: project,
          measurementId: measurementId,
        );
      },
    ),

    GoRoute(
      path: '/measurement_qr/:projectId/:block/:plot',
      name: 'measurement-detail-qr',
      builder: (context, state) {
        final projectId = state.pathParameters['projectId']!;
        final blockIndex = int.parse(state.pathParameters['block']!);
        final plotIndex = int.parse(state.pathParameters['plot']!);

        return MeasurementDetailScreen.fromQR(
          projectId: projectId,
          blockIndex: blockIndex,
          plotIndex: plotIndex,
        );
      },
    ),



    GoRoute(
      path: '/general_info_project',
      builder: (context, state) {
        final project = state.extra is Map<String, dynamic>
            ? (state.extra as Map<String, dynamic>)['project'] as ProjectResponse?
            : null;

        final isEditMode = state.extra is Map<String, dynamic>
            ? (state.extra as Map<String, dynamic>)['isEditMode'] as bool? ?? false
            : false;

        return GeneralInfoScreen(
          project: project,
          isEditMode: isEditMode,
        );
      },
    ),

    GoRoute(
      path: '/factor_level_project',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final project = extra?['project'] as ProjectResponse?;
        final isEditMode = extra?['isEditMode'] as bool? ?? false;

        return FactorLevelScreen(
          project: project,
          isEditMode: isEditMode,
        );
      },
    ),

    GoRoute(
      path: '/criterion_project',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        final isEditMode = extra?['isEditMode'] as bool? ?? false;
        final project = extra?['project'] as ProjectResponse?;

        return CriterionScreen(
          project: project,
          isEditMode: isEditMode,
        );
      },
    ),

    GoRoute(
      path: '/experiment_layout',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;

        final isEditMode = extra?['isEditMode'] as bool? ?? false;
        final project = extra?['project'] as ProjectResponse?;

        return ExperimentLayoutScreen(
          project: project,
          isEditMode: isEditMode,
        );
      },
    ),






    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfileScreen(),
    ),
    GoRoute(
      path: '/project_management',
      builder: (context, state) => ProjectManagementScreen(),
    ),
    GoRoute(
      path: '/project_detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProjectDetailScreen(projectId: id);
      },
    ),
    GoRoute(
      path: '/otp_verify',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return OtpVerifyScreen(
          email: data['email'],
          purpose: data['purpose'],
        );
      },
    ),



    GoRoute(
      path: '/forgot_password',
      builder: (context, state) {
        return ForgotPasswordScreen();
      },
    ),


    GoRoute(
      path: '/forgot_password',
      builder: (context, state) {
        return ForgotPasswordScreen();
      },
    ),


    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final extra = state.extra as Map<String, String?>;
        final resetToken = extra['resetToken'] ?? '';
        final email = extra['email'] ?? '';

        return NewPasswordScreen(
          resetToken: resetToken,
          email: email,
        );
      },
    ),


    GoRoute(
      path: '/scan_qr',
      name: 'scan_qr',
      builder: (context, state) => QRScannerScreen(),
    ),

    GoRoute(
      path: '/click_scan',
      name: 'click_scan',
      builder: (context, state) => ClickScanScreen(),
    ),

    GoRoute(
      path: '/success',
      builder: (context, state) {
        final args = state.extra as SuccessScreenArgs;
        return CustomSuccessScreen(
          title: args.title,
          message: args.message,
          animationAsset: args.animationAsset,
          showButton: args.showButton,
          buttonText: args.buttonText,
          onButtonPressed: args.onButtonPressed,
          autoRedirectDelay: args.autoRedirectDelay,
          onAutoRedirect: args.onAutoRedirect,
        );
      },
    ),
    GoRoute(
      path: '/add_measurement',
      builder: (context, state) {
        logger.i("Route Extra: ${state.extra}");
        final args = state.extra as AddMeasurementArgs;
        return AddMeasurementScreen(
          project: args.project,
          measurements: args.measurements,
          measurementToEdit: args.measurementToEdit,
        );
      },
    ),


  ],
);
