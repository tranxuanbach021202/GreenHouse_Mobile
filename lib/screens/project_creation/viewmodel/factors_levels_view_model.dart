import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:greenhouse/models/factor_model.dart';
import 'package:greenhouse/models/response/treatment_response.dart';
import 'package:greenhouse/screens/project_creation/project_setup_provider.dart';

import '../../../base/viewmodels/base_view_model.dart';
import '../../../models/level_model.dart';
import '../../../models/response/factor_response.dart';
import '../../../models/response/project_response.dart';
import '../../../utils/logger.dart';

class FactorsLevelsViewModel extends BaseViewModel {
  final ProjectSetupProvider _projectSetupProvider;

  FactorsLevelsViewModel({
    required ProjectSetupProvider projectSetupProvider
  }) : _projectSetupProvider = projectSetupProvider ;

  ProjectResponse? _project;

  void setProject(ProjectResponse project) {
    _project = project;
  }



  String _factorCode = '';
  String _factorName = '';
  List<Level> _levels = [];

  // text controller
  final _formKey = GlobalKey<FormState>();
  final TextEditingController factorCodeController = TextEditingController();
  final TextEditingController factorNameController = TextEditingController();
  List<TextEditingController> _controllersLevelCode = [];
  List<TextEditingController> _controllersLevelDetails = [];

  // Getters
  String get factorCode => _factorCode;
  String get factorName => _factorName;
  List<Level> get levels => _levels;
  List<TextEditingController> get controllersLevelCode => _controllersLevelCode;
  List<TextEditingController> get controllersLevelDetails => _controllersLevelDetails;

  @override
  FutureOr<void> init() async {

    logger.i("FactorsLevelsViewModel initialized");
    if (_levels.isNotEmpty) return;

    _factorCode = '';
    _factorName = '';
    _levels = [
      Level(code: '', name: ''),
      Level(code: '', name: ''),
    ];

    _controllersLevelCode = [
      TextEditingController(),
      TextEditingController(),
    ];

    _controllersLevelDetails = [
      TextEditingController(),
      TextEditingController(),
    ];
  }

  void setFromFactorResponse(FactorResponse factor) {
    logger.i("Setting from FactorResponse: ${factor.factorCode}");
    factorCodeController.text = factor.factorCode ?? '';
    factorNameController.text = factor.factorName ?? '';
    _levels = factor.levels.map((e) => Level(id: e.id, code: e.levelCode, name: e.levelName)).toList();


    _controllersLevelCode = _levels.map((e) => TextEditingController(text: e.code)).toList();
    _controllersLevelDetails = _levels.map((e) => TextEditingController(text: e.name)).toList();

    notifyListeners();
    // reloadState();
  }


  void syncFromControllers() {
    logger.i("Syncing from controllers");
    _factorCode = factorCodeController.text.trim();
    _factorName = factorNameController.text.trim();

    _levels = List.generate(_controllersLevelCode.length, (index) {
      final code = _controllersLevelCode[index].text.trim();
      final name = _controllersLevelDetails[index].text.trim();

      final oldLevel = index < _levels.length ? _levels[index] : null;

      return Level(
        id: oldLevel?.id, // giữ lại id cũ nếu có
        code: code,
        name: name,
      );
    });
  }


  void addLevel(Level level) {
    try {
      logger.i("members " +_projectSetupProvider.members.toString());
      _levels.add(level);
      _controllersLevelCode.add(TextEditingController(text: level.code));
      _controllersLevelDetails.add(TextEditingController(text: level.name));
      reloadState();
    } catch (e) {
      logger.e("Lỗi khi thêm level: $e");

    }
  }

  void removeLevel(int index) {
    try {
      if (index >= 0 && index < _levels.length) {
        _levels.removeAt(index);
        _controllersLevelCode[index].dispose();
        _controllersLevelDetails[index].dispose();
        _controllersLevelCode.removeAt(index);
        _controllersLevelDetails.removeAt(index);
        reloadState();
      }
    } catch (e) {
      logger.e("Lỗi khi xóa level: $e");
      setError("Không thể xóa mức độ");
    }
  }

  // void updateLevel(int index, {String? code, String? details}) {
  //   try {
  //     if (index >= 0 && index < _levels.length) {
  //       if (code != null) {
  //         _levels[index] = _levels[index].copyWith(code: code);
  //         _controllersLevelCode[index].text = code;
  //       }
  //       if (details != null) {
  //         _levels[index] = _levels[index].copyWith(details: details);
  //         _controllersLevelDetails[index].text = details;
  //       }
  //       reloadState();
  //     }
  //   } catch (e) {
  //     logger.e("Lỗi khi cập nhật level: $e");
  //     setError("Không thể cập nhật mức độ");
  //   }
  // }

  // // Validate data
  // bool validateData() {
  //   if (_factorCode.isEmpty) {
  //     setError("Vui lòng nhập mã yếu tố");
  //     return false;
  //   }
  //
  //   if (_factorName.isEmpty) {
  //     setError("Vui lòng nhập tên yếu tố");
  //     return false;
  //   }
  //
  //   for (var level in _levels) {
  //     if (level.code.isEmpty || level.name.isEmpty) {
  //       setError("Vui lòng nhập đầy đủ thông tin cho tất cả các mức độ");
  //       return false;
  //     }
  //   }
  //
  //   return true;
  // }

  Future<bool> saveFactorsAndLevels(bool isEditMode) async {
    try {
      isLoading = true;
      syncFromControllers();

      // if (!validateData()) return false;

      if (isEditMode && _project!.factor != null) {
        // Cập nhật factor
        _project!.factor!
          ..factorCode = _factorCode
          ..factorName = _factorName
          ..levels = _levels.map((level) => LevelResponse(
            id: level.id ?? '',
            levelCode: level.code,
            levelName: level.name,
          )).toList();

        // Log chi tiết
        final factor = _project!.factor!;
        logger.i("✅ Factor cập nhật:\n"
            "ID: ${factor.id}\n"
            "Code: ${factor.factorCode}\n"
            "Name: ${factor.factorName}\n"
            "Levels:\n${factor.levels.map((e) => ' - [${e.id}] ${e.levelCode} - ${e.levelName}').join('\n')}");
      } else {
        // Nếu là tạo mới
        final newFactor = Factor(
          code: _factorCode,
          name: _factorName,
          levels: _levels,
        );
        _projectSetupProvider.setFactor(newFactor);
      }

      return true;
    } catch (e) {
      logger.e("❌ Lỗi khi lưu factor & levels: $e");
      setError("Đã xảy ra lỗi khi lưu");
      return false;
    } finally {
      isLoading = false;
    }
  }








  @override
  void dispose() {
    // Cleanup controllers
    for (var controller in _controllersLevelCode) {
      controller.dispose();
    }
    for (var controller in _controllersLevelDetails) {
      controller.dispose();
    }
    super.dispose();
  }
}
