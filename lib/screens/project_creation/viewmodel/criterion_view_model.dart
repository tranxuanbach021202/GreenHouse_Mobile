import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:greenhouse/models/criterion_model.dart';

import '../../../base/viewmodels/base_view_model.dart';
import '../../../models/request/update__factor_and_criterion_request.dart';
import '../../../models/response/criterion_response.dart';
import '../../../models/response/project_response.dart';
import '../../../respositories/project_repository.dart';
import '../../../utils/logger.dart';
import '../project_setup_provider.dart';


class CriterionViewModel extends BaseViewModel {

  final ProjectSetupProvider _projectSetupProvider;
  final ProjectRepository? _projectRepository;

  CriterionViewModel({
    required ProjectSetupProvider projectSetupProvider,
    ProjectRepository? projectRepository,
  })  : _projectSetupProvider = projectSetupProvider,
        _projectRepository = projectRepository;

  List<Criterion> _criterions = [];
  List<TextEditingController> _criterionCodeControllers = [];
  List<TextEditingController> _criterionNameControllers = [];

  // Getters
  List<Criterion> get criterions => _criterions;
  List<TextEditingController> get criterionCodeControllers => _criterionCodeControllers;
  List<TextEditingController> get criterionNameControllers => _criterionNameControllers;


  @override
  FutureOr<void> init() async {
    try {
      _criterions = [
        Criterion(criterionCode: '', criterionName: ''),
        Criterion(criterionCode: '', criterionName: ''),
      ];

      _criterionCodeControllers = [
        TextEditingController(),
        TextEditingController(),
      ];

      _criterionNameControllers = [
        TextEditingController(),
        TextEditingController(),
      ];

      clearError();
    } catch (e) {
      logger.e("Lỗi khởi tạo CriterionViewModel: $e");
      setError("Không thể khởi tạo dữ liệu");
    }
  }

  ProjectResponse? _project;

  ProjectResponse? get project => _project;

  void setProject(ProjectResponse project) {
    _project = project;
  }

  void addCriterion(Criterion criterion) {
    try {
      _criterions.add(criterion);
      _criterionCodeControllers.add(TextEditingController(text: criterion.criterionCode));
      _criterionNameControllers.add(TextEditingController(text: criterion.criterionName));
      reloadState();
    } catch (e) {
      logger.e("Lỗi khi thêm tiêu chí: $e");
      setError("Không thể thêm tiêu chí mới");
    }
  }

  void removeCriterion(int index) {
    try {
      if (index >= 0 && index < _criterions.length) {
        _criterions.removeAt(index);
        _criterionCodeControllers[index].dispose();
        _criterionCodeControllers.removeAt(index);
        _criterionNameControllers[index].dispose();
        _criterionNameControllers.removeAt(index);
        reloadState();
      }
    } catch (e) {
      logger.e("Lỗi khi xóa tiêu chí: $e");
      setError("Không thể xóa tiêu chí");
    }
  }

  bool validateCriterions() {
    if (_criterions.isEmpty) {
      setError("Vui lòng thêm ít nhất một tiêu chí");
      return false;
    }

    for (var criterion in _criterions) {
      if (criterion.criterionCode.isEmpty) {
        setError("Vui lòng nhập mã cho tất cả các tiêu chí");
        return false;
      }
      if (criterion.criterionName.isEmpty) {
        setError("Vui lòng nhập chi tiết cho tất cả các tiêu chí");
        return false;
      }
    }

    return true;
  }

  void syncFromControllers() {
    _criterions = List.generate(_criterionCodeControllers.length, (index) {
      final code = _criterionCodeControllers[index].text.trim();
      final name = _criterionNameControllers[index].text.trim();
      final old = index < _criterions.length ? _criterions[index] : null;

      return Criterion(
        id: old?.id,
        criterionCode: code,
        criterionName: name,
      );
    });

  }




  void setFromCriterionResponses(List<CriterionResponse> responses) {
    logger.i("Criterion responses" + responses.toString());
    _criterions = responses.map((e) => Criterion(
      id: e.id,
      criterionCode: e.criterionCode,
      criterionName: e.criterionName,
    )).toList();


    _criterionCodeControllers = _criterions
        .map((e) => TextEditingController(text: e.criterionCode))
        .toList();

    _criterionNameControllers = _criterions
        .map((e) => TextEditingController(text: e.criterionName))
        .toList();

    notifyListeners();
  }


  Future<bool> saveCriterion(bool isEditMode) async {
    try {

      logger.i("Lưu thông tin chỉ tiêu");
      isLoading = true;
      syncFromControllers();

      // if (!validateCriterions()) return false;

      if (isEditMode && _project != null) {
        // ✅ Cập nhật vào ProjectResponse
        _project!.criteria = _criterions.map((e) => CriterionResponse(
          id: e.id ?? '',
          criterionCode: e.criterionCode,
          criterionName: e.criterionName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )).toList();

        final logStr = _project!.criteria.map((e) =>
        "- [${e.id ?? '(mới)'}] ${e.criterionCode} - ${e.criterionName}"
        ).join("\n");

        logger.i("📋 Danh sách chỉ tiêu đã lưu:\n$logStr");


        // Log chi tiết
        final factor = _project!.factor!;
        logger.i("✅ Factor cập nhật:\n"
            "ID: ${factor.id}\n"
            "Code: ${factor.factorCode}\n"
            "Name: ${factor.factorName}\n"
            "Levels:\n${factor.levels.map((e) => ' - [${e.id}] ${e.levelCode} - ${e.levelName}').join('\n')}");
      } else {
        // ✅ Trường hợp tạo mới, lưu tạm qua provider
        _projectSetupProvider.setCriterion(_criterions);
      }

      logger.i("Lưu thông tin chỉ tiêu 2");
      return true;
    } catch (e) {
      logger.e("❌ Lỗi khi lưu chỉ tiêu: $e");
      setError('Có lỗi xảy ra khi lưu dữ liệu');
      return false;
    } finally {
      isLoading = false;
    }
  }





  @override
  void dispose() {
    // Cleanup controllers
    for (var controller in _criterionCodeControllers) {
      controller.dispose();
    }
    for (var controller in _criterionNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
