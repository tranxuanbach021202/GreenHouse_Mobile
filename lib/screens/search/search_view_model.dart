import 'package:flutter/material.dart';
import 'package:greenhouse/screens/dashboard/project_short_model.dart';
import 'package:greenhouse/respositories/project_repository.dart';
import 'package:greenhouse/di/di.dart';

class SearchProjectViewModel extends ChangeNotifier {
  final ProjectRepository _projectRepository = getIt<ProjectRepository>();

  List<ProjectShort> _results = [];
  bool _isLoading = false;

  List<ProjectShort> get results => _results;
  bool get isLoading => _isLoading;

  Future<void> search(String keyword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _projectRepository.searchProjects(keyword: keyword);
      final items = (data['content'] as List)
          .map((json) => ProjectShort.fromJson(json))
          .toList();

      _results = items;
    } catch (e) {
      // handle or log error if needed
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
