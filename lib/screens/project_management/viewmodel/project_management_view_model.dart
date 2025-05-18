import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greenhouse/base/viewmodels/base_view_model.dart';
import 'package:greenhouse/models/response/project_model_response.dart';
import 'package:greenhouse/respositories/project_repository.dart';

import '../../../models/response/api_response.dart';

class ProjectManagementViewModel extends BaseViewModel {
  final ProjectRepository _projectRepository;
  List<ProjectModelResponse> _projects = [];
  int _page = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isInitialLoading = true;

  List<ProjectModelResponse> get projects => _projects;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;

  ProjectManagementViewModel(this._projectRepository);

  Future<void> loadProjects() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _projectRepository.getProjectsUser();
      final apiResponse = ApiResponse<List<ProjectModelResponse>>.fromJson(
        response as Map<String, dynamic>,
            (data) => (data as List)
            .map((e) => ProjectModelResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      _projects = apiResponse.data;
    } catch (e) {
      setError("Không thể tải dự án");
    } finally {
      _isLoading = false;
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  @override
  FutureOr<void> init() {
    print("Load dữ liệu");
    loadProjects();
  }
}
