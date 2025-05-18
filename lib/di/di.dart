import 'package:get_it/get_it.dart';
import 'package:greenhouse/network_service/cloud_storage_service.dart';
import 'package:greenhouse/respositories/device_token_repository.dart';
import 'package:greenhouse/respositories/measurement_repository.dart';
import 'package:greenhouse/respositories/project_repository.dart';
import 'package:greenhouse/respositories/cloud_repository.dart';
import 'package:greenhouse/screens/otp_verify/viewmodel/otp_verify_view_model.dart';
import 'package:greenhouse/screens/profile%20/edit_profile/edit_profile_view_model.dart';
import 'package:greenhouse/screens/profile%20/viewmodel/profile_view_model.dart';
import 'package:greenhouse/screens/project_creation/viewmodel/criterion_view_model.dart';
import 'package:greenhouse/screens/project_creation/viewmodel/experiment_layout_view_model.dart';
import 'package:greenhouse/screens/project_creation/viewmodel/factors_levels_view_model.dart';
import 'package:greenhouse/screens/project_creation/viewmodel/general_info_view_model.dart';
import 'package:greenhouse/screens/project_creation/viewmodel/member_permissions_view_model.dart';
import 'package:greenhouse/screens/project_management/viewmodel/project_management_view_model.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../base/services/localization_service.dart';
import '../base/services/navigation_service.dart';
import '../base/services/storage_service.dart';
import '../network_service/api_service.dart';
import '../respositories/auth_repository.dart';
import '../respositories/invitation_repository.dart';
import '../respositories/user_repository.dart';
import '../screens/dashboard/viewmodel/dashboard_view_model.dart';
import '../screens/forgot_password_screen/viewmodel/forgot_pass_work_view_model.dart';
import '../screens/invitations/viewmodel/invitation_view_model.dart';
import '../screens/project_creation/project_setup_provider.dart';
import '../screens/project_detail/measurement/viewmodel/add_measurement_view_model.dart';
import '../screens/signin/viewmodel/signin_view_model.dart';
import '../screens/signup/viewmodel/signup_view_model.dart';
import '../screens/splash/viewmodel/splash_view_model.dart';




final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {

  // getIt.registerLazySingleton<LocalizationService>(() => LocalizationService());

  getIt.registerSingletonAsync<SharedPreferences>(
        () async => await SharedPreferences.getInstance(),
  );

  // Api Serivce
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  getIt.registerLazySingleton<CloudStorageService>(() => CloudStorageService());

  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepository(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<UserRepository>(
        () => UserRepository(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<ProjectRepository>(
        () => ProjectRepository(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<CloudRepository>(
        () => CloudRepository(getIt<ApiService>(), getIt<CloudStorageService>()),
  );

  getIt.registerLazySingleton<MeasurementRepository>(
        () => MeasurementRepository(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<DeviceTokenRepository>(
        () => DeviceTokenRepository(getIt<ApiService>()),
  );

  getIt.registerLazySingleton(() => InvitationRepository(getIt<ApiService>()));





  getIt.registerLazySingleton<NavigationService>(
        () => NavigationService(),
  );

  getIt.registerLazySingleton<StorageService>(
        () => StorageService(getIt<SharedPreferences>())
  );

  // ViewModels
  getIt.registerFactory<SplashViewModel>(
          () => SplashViewModel(getIt<StorageService>()));



  getIt.registerFactory<SignInViewModel>(
        () => SignInViewModel(
      authRepository: getIt<AuthRepository>(),
      navigationService: getIt<NavigationService>(),
      storageService : getIt<StorageService>(),
      deviceTokenRepository: getIt<DeviceTokenRepository>()

    ),
  );

  getIt.registerFactory<SignUpViewModel>(
        () => SignUpViewModel(
        authRepository: getIt<AuthRepository>(),
        navigationService: getIt<NavigationService>(),
        storageService : getIt<StorageService>()
    ),
  );

  getIt.registerFactory<OtpVerifyViewModel>(
        () => OtpVerifyViewModel(
        authRepository: getIt<AuthRepository>(),
        navigationService: getIt<NavigationService>()
    ),
  );



  getIt.registerLazySingleton<ProjectSetupProvider>(() => ProjectSetupProvider(
    projectRepository: getIt<ProjectRepository>(),
    navigationService: getIt<NavigationService>(),
    cloudRepository: getIt<CloudRepository>(),
  ));


  getIt.registerFactoryParam<GeneralInfoViewModel, bool, void>((isEditMode, _) {
    if (isEditMode) {
      return GeneralInfoViewModel.forEdit(
        projectRepository: getIt<ProjectRepository>(),
        cloudRepository: getIt<CloudRepository>(),
      );
    } else {
      return GeneralInfoViewModel.forCreate(
        setupProvider: getIt<ProjectSetupProvider>(),
        cloudRepository: getIt<CloudRepository>(),
      );
    }
  });


  getIt.registerFactory<MemberPermissionsViewModel>(
        () => MemberPermissionsViewModel(
        userRepository: getIt<UserRepository>(),
        storageService : getIt<StorageService>(),
        projectSetupProvider: getIt<ProjectSetupProvider>(),
          projectRepository: getIt<ProjectRepository>(),
    ),
  );

  getIt.registerFactory<FactorsLevelsViewModel>(
      () => FactorsLevelsViewModel(
          projectSetupProvider: getIt<ProjectSetupProvider>()
      )
  );

  getIt.registerFactoryParam<CriterionViewModel, bool, void>((isEditMode, _) {
    return CriterionViewModel(
      projectSetupProvider: getIt<ProjectSetupProvider>(),
      projectRepository: isEditMode ? getIt<ProjectRepository>() : null,
    );
  });


  getIt.registerFactory<ExperimentLayoutViewModel>(
          () => ExperimentLayoutViewModel(
          projectSetupProvider: getIt<ProjectSetupProvider>()
      )
  );

  getIt.registerFactory<DashboardViewModel>(
        () => DashboardViewModel(
      navigationService: getIt<NavigationService>(),
      projectRepository: getIt<ProjectRepository>()
    ),
  );


  getIt.registerFactory<EditProfileViewModel>(
        () => EditProfileViewModel(cloudRepository: getIt<CloudRepository>(),
                                  userRepository: getIt<UserRepository>())
  );

  getIt.registerFactory(() => InvitationViewModel(getIt<InvitationRepository>()));

  getIt.registerFactory(() => ProjectManagementViewModel(getIt<ProjectRepository>()));

  getIt.registerFactory(() => AddMeasurementViewModel(
    measurementRepository: getIt<MeasurementRepository>(),
  ));

  getIt.registerFactory(() => ProfileViewModel(userRepository: getIt<UserRepository>(), authRepository: getIt<AuthRepository>()));

  getIt.registerFactory(() => ForgotPasswordViewModel(
    authRepository: getIt<AuthRepository>()
  ));


  await getIt.allReady();
}
