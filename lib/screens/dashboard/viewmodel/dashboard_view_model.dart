
import 'package:greenhouse/core/router/app_router.dart';
import 'package:greenhouse/respositories/project_repository.dart';
import 'package:greenhouse/screens/dashboard/project_short_model.dart';
import 'package:greenhouse/utils/logger.dart';

import '../../../base/services/navigation_service.dart';
import '../../../base/viewmodels/base_view_model.dart';
import '../../../models/response/api_response.dart';
import '../../../models/response/pagination.dart';

class DashboardViewModel extends BaseViewModel {
  final NavigationService _navigationService;
  final ProjectRepository _projectRepository;
  int _currentIndex = 0;

  DashboardViewModel({
    required NavigationService navigationService,
    required ProjectRepository projectRepository
  }) : _navigationService = navigationService,
       _projectRepository = projectRepository;

  List<ProjectShort> _popularProjects = [];
  List<ProjectShort> _myProjects = [];

  List<ProjectShort> get popularProjects => _popularProjects;
  List<ProjectShort> get myProjects => _myProjects;

  List<ProjectShort> _publicProjects = [];
  List<ProjectShort> get publicProjects => _publicProjects;


  List<ProjectShort> _projectsSearch = [];
  List<ProjectShort> get projects => _projectsSearch;


  Pagination? _meta;
  Pagination? get meta => _meta;

  int get currentIndex => _currentIndex;

  void onBottomNavTapped(int index) {
    if (index == 1) {
      _navigationService.push('/general_info_project');
      return;
    } else if (index == 3) {
      _navigationService.push('/profile');
      return;
    }

    _currentIndex = index;
    notifyListeners();
  }

  @override
  Future<void> init() async {
    try {
      logger.i("init dashboard");
      await Future.wait([
        fetchProjects(),
        fetchPublicProjects(),
      ]);
    } catch (e) {
      setError(e.toString());
    }
  }


  Future<void> fetchProjects() async {
    try {
      isLoading = true;
      logger.i("project api 0");
      final response = await _projectRepository.getProjectsAsMemberOrGuest();
      logger.i("project api 1");
      final apiResponse = ApiResponse<List<ProjectShort>>.fromJson(
        response as Map<String, dynamic>,
            (data) => (data as List)
            .map((e) => ProjectShort.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      logger.i("proect" + apiResponse.data.toString());
      _myProjects = apiResponse.data;
      _meta = apiResponse.meta;
      notifyListeners();
      clearError();
    } catch (e) {
      logger.e("Lỗi fetchProjects: $e", error: e);
      setError('Không thể tải dữ liệu: ${e.toString()}');
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchPublicProjects() async {
    try {
      isLoading = true;
      logger.i("project public api 0");

      final response = await _projectRepository.getPublicProjects();
      logger.i("project public api 1");

      final apiResponse = ApiResponse<List<ProjectShort>>.fromJson(
        response as Map<String, dynamic>,
            (data) => (data as List)
            .map((e) => ProjectShort.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      _publicProjects = apiResponse.data;
      notifyListeners();
      clearError();
    } catch (e) {
      logger.e("Lỗi fetchPublicProjects: $e", error: e);
      setError('Không thể tải dự án công khai: ${e.toString()}');
    } finally {
      isLoading = false;
    }
  }


  Future<void> refreshData() async {
    await Future.wait([
      fetchProjects(),
      fetchPublicProjects(),
    ]);
  }

  Future<void> searchProjects(String keyword) async {
    isLoading = true;
    clearError();

    try {
      final response = await _projectRepository.searchProjects(keyword: keyword);
      final apiResponse = ApiResponse<List<ProjectShort>>.fromJson(
        response as Map<String, dynamic>,
            (data) => (data as List)
            .map((e) => ProjectShort.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      _projectsSearch = apiResponse.data;
      notifyListeners();
      logger.i("🔍 Search results: ${apiResponse.data} dự án");
    } catch (e) {
      setError("Không thể tìm kiếm dự án: $e");
    } finally {
      isLoading = false;
    }
  }

}
