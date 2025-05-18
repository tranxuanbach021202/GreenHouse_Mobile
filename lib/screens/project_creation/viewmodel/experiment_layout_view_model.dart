import 'dart:async';

import 'package:greenhouse/models/enums/experiment_type.dart';

import '../../../base/viewmodels/base_view_model.dart';
import '../../../models/experiment_layout.dart';
import '../../../models/response/project_response.dart';
import '../../../models/response/treatment_response.dart';
import '../../../models/treatment.dart';
import '../../../utils/logger.dart';
import '../project_setup_provider.dart';

class ExperimentLayoutViewModel extends BaseViewModel {
  final ProjectSetupProvider _projectSetupProvider;

  ExperimentLayoutViewModel({
    required ProjectSetupProvider projectSetupProvider,
  }) : _projectSetupProvider = projectSetupProvider;

  ProjectResponse? _project;
  bool _isEditMode = false;

  // State
  int _blocks = 1;
  int _replicates = 1;
  int _columnsInBlock = 4;
  ExperimentType _designType = ExperimentType.RCBD;
  List<Treatment> _treatments = [];
  List<List<String>> _layout = [];



  // Getter
  bool get isCRD => _designType == ExperimentType.RCD;
  bool get isRCBD => _designType == ExperimentType.RCBD;
  int get blocks => _blocks;
  int get replicates => _replicates;
  int get columnsInBlock => _columnsInBlock;
  ExperimentType get designType => _designType;
  List<Treatment> get treatments => _treatments;
  List<List<String>> get layout => _layout;

  Future<void> initWithData({
    required ProjectResponse? project,
    required bool isEditMode,
  }) async {
    try {
      _isEditMode = isEditMode;

      if (_isEditMode) {
        _project = project;
      }

      if (_isEditMode && _project != null) {
        _blocks = _project!.blocks;
        _replicates = _project!.replicates;
        _columnsInBlock = _project!.columns;
        _designType = _project!.experimentType == 'RCD'
            ? ExperimentType.RCD
            : ExperimentType.RCBD;

        _treatments = _project!.factor?.levels
            .map((e) => Treatment(code: e.levelCode ?? '', name: e.levelName ?? ''))
            .toList() ?? [];

        final levels = _project!.factor?.levels ?? [];
        final hasInvalidId = levels.any((l) => l.id == null || l.id!.isEmpty);

        final expected = _treatments.length * _replicates;
        final actual = _project!.layout.expand((row) => row).length;

        if (!hasInvalidId && expected == actual) {
          // ✅ Tạo map levelId -> treatmentCode
          final levelIdToCode = {
            for (final level in _project!.factor!.levels)
              if (level.id != null) level.id!: level.levelCode ?? ''
          };

          // ✅ Cập nhật lại treatmentCode trong danh sách treatment
          for (final treatment in _project!.treatments) {
            if (treatment.levelId != null && levelIdToCode.containsKey(treatment.levelId)) {
              treatment.treatmentCode = levelIdToCode[treatment.levelId]!;
            }
          }

          // ✅ Dùng lại layout cũ, ánh xạ idTreatment → treatmentCode đã cập nhật
          _layout = _project!.layout.map((row) {
            return row.map((cell) {
              final treatment = _project!.treatments.firstWhere(
                    (t) => t.id == cell.idTreatment,
              );
              return treatment.treatmentCode ?? '';
            }).toList();
          }).toList();
        } else {
          // ❌ Layout không khớp hoặc có level mới chưa có id → tạo lại
          await _generateLayout();
        }
      } else {
        // Trường hợp tạo mới
        _blocks = 1;
        _replicates = 1;
        _designType = ExperimentType.RCBD;

        if (_projectSetupProvider.treatments != null) {
          _treatments = _projectSetupProvider.treatments!;
          if (_treatments.isNotEmpty) {
            _columnsInBlock = _treatments.length;
          }
        }

        await _generateLayout();
      }

      clearError();
      notifyListeners();
    } catch (e) {
      logger.e("❌ Lỗi khởi tạo layout: $e");
      setError("Không thể khởi tạo layout");
    }
  }






  Future<void> setTreatments(List<Treatment> treatments) async {
    try {
      if (treatments.isEmpty) {
        setError("Treatment list cannot be empty");
        return;
      }

      _treatments = treatments;
      await _generateLayout();
      notifyListeners();
    } catch (e) {
      logger.e("Error updating treatments: $e");
      setError("Cannot update treatment list");
    }
  }

  Future<void> setBlocks(int value) async {
    try {
      // Prevent setting blocks below 1
      if (value < 1) {
        return;
      }

      _blocks = value;
      await _generateLayout();
      notifyListeners();
    } catch (e) {
      logger.e("Error updating blocks: $e");
      setError("Cannot update number of blocks");
    }
  }

  Future<void> setReplicates(int value) async {
    try {
      // Prevent setting replicates below 1
      if (value < 1) {
        return;
      }

      _replicates = value;
      await _generateLayout();
      notifyListeners();
    } catch (e) {
      logger.e("Error updating replicates: $e");
      setError("Cannot update number of replicates");
    }
  }

  Future<void> setColumnsInBlock(int value) async {
    try {
      // Prevent setting columns below 1
      if (value < 1) {
        return;
      }

      _columnsInBlock = value;
      await _generateLayout();
      notifyListeners();
    } catch (e) {
      logger.e("Error updating columns in block: $e");
      setError("Cannot update number of columns in block");
    }
  }

  Future<void> setDesignType(ExperimentType value) async {
    try {
      _designType = value;
      if (value == ExperimentType.RCD) {
        _blocks = 1;
      }

      _replicates = 1;
      await _generateLayout();
      notifyListeners();
    } catch (e) {
      logger.e("Error updating design type: $e");
      setError("Cannot update design type");
    }
  }

  Future<void> _generateLayout() async {
    try {
      isLoading = true;
      notifyListeners();

      _layout.clear();
      if (_designType == ExperimentType.RCBD) {
        await _generateRCBDLayout();
      } else {
        await _generateCRDLayout();
      }
    } catch (e) {
      logger.e("Error generating layout: $e");
      setError("Cannot generate experiment layout");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _generateRCBDLayout() async {
    try {
      _layout.clear();

      for (int block = 0; block < _blocks; block++) {
        List<Treatment> shuffledTreatments = List.from(_treatments)..shuffle();
        List<String> blockLayout = shuffledTreatments.map((t) => t.code).toList();
        _layout.add(blockLayout);
      }
    } catch (e) {
      logger.e("Error generating RCBD layout: $e");
      throw Exception("Cannot generate RCBD layout");
    }
  }

  Future<void> _generateCRDLayout() async {
    try {
      _layout.clear();
      int totalSlots = _treatments.length * _replicates;

      // Create treatment codes list based on replicates
      List<String> treatmentCodes = [];
      for (var treatment in _treatments) {
        for (int i = 0; i < _replicates; i++) {
          treatmentCodes.add(treatment.code);
        }
      }

      // Randomize positions
      treatmentCodes.shuffle();

      // For CRD we only need one block
      _layout.add(treatmentCodes);
    } catch (e) {
      logger.e("Error generating CRD layout: $e");
      throw Exception("Cannot generate CRD layout");
    }
  }

  Future<void> regenerateLayout() async {
    try {
      await _generateLayout();
    } catch (e) {
      logger.e("Error regenerating layout: $e");
      setError("Cannot regenerate experiment layout");
    }
  }

  bool validateLayout() {
    if (_treatments.isEmpty) {
      setError("Treatment list cannot be empty");
      return false;
    }

    if (_blocks <= 0) {
      setError("Number of blocks must be greater than 0");
      return false;
    }

    if (_replicates <= 0) {
      setError("Number of replicates must be greater than 0");
      return false;
    }

    if (_columnsInBlock <= 0) {
      setError("Number of columns in block must be greater than 0");
      return false;
    }

    return true;
  }

  ExperimentLayout getExperimentLayout() {
    return ExperimentLayout(
      blocks: _blocks,
      replicates: _replicates,
      columnsInBlock: _columnsInBlock,
      designType: _designType,
      layout: _layout,
    );
  }

  Future<bool> saveExperimentLayout() async {
    try {
      isLoading = true;
      notifyListeners();

      _projectSetupProvider.setExperimentConfig(
        experimentType: _designType,
        blocks: _blocks,
        replicates: _replicates,
        columns: _columnsInBlock,
        layout: layout
      );

      logger.i("Experiment layout saved successfully");
      return true;
    } catch (e) {
      logger.e("Error saving experiment layout: $e");
      setError('Error occurred while saving information');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProject() async {
    try {
      isLoading = true;
      notifyListeners();

      await _projectSetupProvider.createProject();
      logger.i("Project created successfully");
    } catch (e) {
      logger.e("Error creating project: $e");
      setError('Error occurred while creating project');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProject() async {
    if (_project == null || _project!.factor == null) {
      setError("Dự án chưa được khởi tạo hoặc thiếu thông tin yếu tố");
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      // 🔹 1. Chuẩn bị danh sách level
      final levels = _project!.factor!.levels.map((level) {
        return {
          "id": level.id,
          "levelCode": level.levelCode,
          "levelName": level.levelName,
        };
      }).toList();

      // 🔹 2. Chuẩn bị danh sách criterion
      final criterions = _project!.criteria.map((criterion) {
        return {
          "id": criterion.id,
          "criterionCode": criterion.criterionCode,
          "criterionName": criterion.criterionName,
        };
      }).toList();

      // 🔹 3. Chuẩn bị layout mới từ treatmentCode → idTreatment
      final layoutToSend = _layout.map((row) {
        return row.map((code) {
          final treatment = _project!.treatments.firstWhere(
                (t) => t.treatmentCode == code,
            orElse: () => throw Exception("Không tìm thấy treatment cho code: $code"),
          );
          return {
            "idTreatment": treatment.id,
            "treatmentCode": treatment.treatmentCode,
            "plantName": null,
          };
        }).toList();
      }).toList();

      // 🔹 4. Gửi API
      final body = {
        "factorId": _project!.factor!.id,
        "factorCode": _project!.factor!.factorCode,
        "factorName": _project!.factor!.factorName,
        "levels": levels,
        "criteria": criterions,
        "experimentType": _designType == ExperimentType.RCD ? "RCD" : "RCBD",
        "blocks": _blocks,
        "replicates": _replicates,
        "columns": _columnsInBlock,
        "layout": layoutToSend,
      };

      final response = await _projectSetupProvider.updateFactorCriteriaAndLayout(projectId: _project!.id, body: body);

      logger.i("Project updated successfully ");
      return true;
    } catch (e) {
      logger.e("❌ Lỗi khi cập nhật dự án: $e");
      setError("Đã xảy ra lỗi khi cập nhật thông tin");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }




  @override
  FutureOr<void> init() {
    // // TODO: implement init
    // throw UnimplementedError();
  }
}

