import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/core/colors.dart';
import 'package:greenhouse/models/response/project_response.dart';
import 'package:greenhouse/models/response/measurement_detail_response.dart';
import 'package:greenhouse/base/viewmodels/base_view_model.dart';
import 'package:greenhouse/models/plot_input_data.dart';
import 'package:get_it/get_it.dart';
import 'package:greenhouse/utils/logger.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../base/services/storage_service.dart';
import '../../../../di/di.dart';
import '../../../../models/response/api_response.dart';
import '../../../../models/response/criterion_response.dart';
import '../../../../respositories/measurement_repository.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greenhouse/models/response/project_response.dart';
import 'package:greenhouse/models/response/measurement_detail_response.dart';
import 'package:greenhouse/base/viewmodels/base_view_model.dart';
import 'package:greenhouse/models/plot_input_data.dart';
import 'package:get_it/get_it.dart';
import 'package:greenhouse/utils/logger.dart';

import '../../../../base/services/storage_service.dart';
import '../../../../di/di.dart';
import '../../../../models/response/api_response.dart';
import '../../../../models/response/criterion_response.dart';
import '../../../../models/response/edit_session_history_response.dart';
import '../../../../respositories/measurement_repository.dart';
import '../../../../respositories/project_repository.dart';


typedef MeasurementCallback = void Function(bool success);

class MeasurementDetailViewModel extends BaseViewModel {
  final MeasurementRepository _measurementRepository;
  final ProjectRepository _projectRepository;

  MeasurementDetailViewModel(
      this._measurementRepository,
      this._projectRepository,
      );


  MeasurementDetailResponse? _measurementDetail;
  ProjectResponse? _project;
  List<PlotInputData> _layout = [];
  List<PlotInputData> get layout => _layout;
  ProjectResponse? get project => _project;
  List<CriterionResponse>? criterions;
  final Set<String> _editedPlots = {};

  MeasurementDetailResponse? get measurementDetail => _measurementDetail;


  Future<void> initializeFromQR(String projectId, int blockIndex, int plotIndex) async {
    isLoading = true;
    try {
      final response = await _projectRepository.getProjectDetail(projectId);
      final apiResponse = ApiResponse<ProjectResponse>.fromJson(
        response as Map<String, dynamic>,
            (data) => ProjectResponse.fromJson(data),
      );


      final project = apiResponse.data;
      setProject(project);

      generateInitialLayoutFromProject(project);

      logger.i("Tải từ QR → block: $blockIndex, plot: $plotIndex");

      notifyListeners();
    } catch (e) {
      setError("Không thể tải dữ liệu từ QR: $e");
    } finally {
      isLoading = false;
    }
  }


  Future<void> initializeFromMeasurement(ProjectResponse project, String measurementId) async {
    setProject(project);
    await fetchMeasurementDetail(measurementId);
  }


  DateTime? startTime;
  DateTime? endTime;

  bool _autoMove = false;
  bool get autoMove => _autoMove;

  void setAutoMove(bool value) {
    _autoMove = value;
    notifyListeners();
  }


  bool isEditMode = false;
  void setEditMode(bool value) {
    isEditMode = value;
    notifyListeners();
  }

  void setProject(ProjectResponse project) {
    _project = project;
    criterions = _project?.criteria;
    notifyListeners();
  }

  List<EditSessionHistoryResponse> editHistories = [];
  String? selectedSessionId;
  void setSelectedSession(String? sessionId) {
    selectedSessionId = sessionId;
    notifyListeners();
  }

  bool isPlotEdited(int blockIndex, int plotIndex) {
    final session = editHistories.firstWhere(
          (e) => e.editSessionId == selectedSessionId,
      orElse: () => EditSessionHistoryResponse(editSessionId: '', userId: '', username: '', urlAvatar: '', timestamp: DateTime.now(), changes: []),
    );
    return session.changes.any((change) =>
    change.blockIndex == blockIndex && change.plotIndex == plotIndex);
  }

  @override
  FutureOr<void> init() {}

  List<CriterionResponse> getCriterionList() {
    return criterions ?? [];
  }

  List<CriterionValue>? getExistingValues(int blockIndex, int plotIndex) {
    final plot = layout.firstWhere(
          (p) => p.blockIndex == blockIndex - 1 && p.plotIndex == plotIndex - 1,
      orElse: () => PlotInputData(
        blockIndex: blockIndex,
        plotIndex: plotIndex,
        treatmentCode: '',
        values: [],
      ),
    );
    return plot.values;
  }

  void saveInput(int blockIndex, int plotIndex, List<CriterionValue> values) {
    final index = layout.indexWhere(
          (p) => p.blockIndex == blockIndex && p.plotIndex == plotIndex,
    );

    if (index != -1) {
      layout[index].values = values;
    } else {
      layout.add(PlotInputData(
        blockIndex: blockIndex,
        plotIndex: plotIndex,
        treatmentCode: '',
        values: values,
      ));
    }

    _editedPlots.add('$blockIndex-$plotIndex');
    notifyListeners();
  }

  bool checkPermission(ProjectResponse project) {
    final currentUserId = getIt<StorageService>().getCurrentUserId();
    return project.members.any(
          (member) =>
      member.userId == currentUserId &&
          (member.role == 'OWNER' || member.role == 'MEMBER'),
    );
  }

  Future<void> fetchMeasurementDetail(String measurementId) async {
    isLoading = true;
    try {
      final response = await _measurementRepository.getMeasurementById(measurementId);
      final apiResponse = ApiResponse<MeasurementDetailResponse>.fromJson(
        response as Map<String, dynamic>,
            (data) => MeasurementDetailResponse.fromJson(data),
      );

      _measurementDetail = apiResponse.data;

      if (_measurementDetail?.records == null || _measurementDetail!.records!.isEmpty) {
        generateInitialLayoutFromProject(_project!);
      } else {
        _layout = _measurementDetail!.records!;
      }

      await fetchEditHistories(measurementId);
      notifyListeners();
    } catch (e) {
      setError('Lỗi khi tải dữ liệu đợt nhập: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchEditHistories(String measurementId) async {
    try {
      final response = await _measurementRepository.getEditHistory(measurementId);
      final apiResponse = ApiResponse<List<EditSessionHistoryResponse>>.fromJson(
        response as Map<String, dynamic>,
            (data) => (data as List).map((e) => EditSessionHistoryResponse.fromJson(e)).toList(),
      );
      editHistories = apiResponse.data;
    } catch (e) {
      logger.e("Lỗi khi tải lịch sử chỉnh sửa: $e");
    }
  }

  Future<void> saveMeasurement() async {
    try {
      if (_layout.isEmpty || _measurementDetail?.id == null) {
        setError("Thiếu dữ liệu hoặc ID đợt nhập không hợp lệ.");
        return;
      }


      final measurementId = _measurementDetail!.id!;
      if (editHistories.isEmpty) {
        logger.i("Chưa có lịch sử chỉnh sửa, thêm mới");
        await _measurementRepository.appendRecordsToMeasurement(measurementId, _layout);
      } else {
        logger.i("Có lịch sử chỉnh sửa, cập nhật");
        await _measurementRepository.updateMeasurementRecords(measurementId, _layout);
      }

      setEditMode(false);
    } catch (e) {
      setError("Lỗi khi lưu dữ liệu đo: $e");
    }
  }


  void generateInitialLayoutFromProject(ProjectResponse project) {
    final layoutFromProject = project.layout;
    final criterions = project.criteria;

    final tempLayout = <PlotInputData>[];

    for (int blockIndex = 0; blockIndex < layoutFromProject.length; blockIndex++) {
      final plots = layoutFromProject[blockIndex];

      for (int plotIndex = 0; plotIndex < plots.length; plotIndex++) {
        final treatmentCode = plots[plotIndex].treatmentCode;

        final values = criterions.map((criterion) {
          return CriterionValue(
            criterionCode: criterion.criterionCode,
            criterionName: criterion.criterionName,
            value: 0.0,
          );
        }).toList();

        tempLayout.add(
          PlotInputData(
            blockIndex: blockIndex,
            plotIndex: plotIndex,
            treatmentCode: treatmentCode,
            values: values,
          ),
        );
      }
    }

    _layout = tempLayout;
    notifyListeners();
  }


  String getSelectedSessionTitle() {
    final selected = editHistories.where((e) => e.editSessionId == selectedSessionId).toList();

    if (selected.isEmpty) return "Chọn phiên";

    final timestamp = DateFormat('dd/MM/yyyy HH:mm').format(selected.first.timestamp);
    return "$timestamp - ${selected.first.username}";
  }

  void setSelectedSessionId(String? id) {
    selectedSessionId = id;
    notifyListeners();
  }


  bool isChangedPlotInSelectedSession(int blockIndex, int plotIndex) {
    final session = editHistories.firstWhereOrNull((e) => e.editSessionId == selectedSessionId);
    if (session == null) return false;
    return session.changes.any((c) => c.blockIndex == blockIndex && c.plotIndex == plotIndex);
  }

  ChangedValue? getChangedValue(int blockIndex, int plotIndex, String criterionCode) {
    final session = editHistories.firstWhereOrNull((e) => e.editSessionId == selectedSessionId);
    if (session == null) return null;

    final change = session.changes.firstWhereOrNull(
          (c) =>
      c.blockIndex == blockIndex &&
          c.plotIndex == plotIndex &&
          c.criterionCode == criterionCode,
    );

    if (change != null) {
      return ChangedValue(oldValue: change.oldValue, newValue: change.newValue);
    }

    return null;
  }

  bool isEditedPlot(int blockIndex, int plotIndex) {
    return _editedPlots.contains('$blockIndex-$plotIndex');
  }

  Future<void> saveMeasurementWithDialog(BuildContext context) async {
    if (_layout.isEmpty) {
      setError("Không có dữ liệu để lưu.");
      return;
    }

    // Nếu chưa có đợt nhập (tức là từ QR)
    if (_measurementDetail == null) {
      try {
        final picked = await _showCustomDateRangeDialog(context);
        if (picked == null) {
          return; // Người dùng đã hủy
        }

        startTime = picked.start;
        endTime = picked.end;

        // Show loading indicator
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final createdId = await _measurementRepository.createNewMeasurement(
          projectId: _project!.id!,
          start: startTime!,
          end: endTime!,
          records: _layout,
        );

        // Hide loading
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        logger.i("✅ Tạo đợt nhập mới thành công: $createdId");
        // await fetchMeasurementDetail(createdId);

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo đợt nhập mới thành công'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

        }

        await Future.delayed(const Duration(seconds: 2));


        context.go("/main_screen");
      } catch (e) {
        // Hide loading if error
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        setError("❌ Lỗi khi tạo đợt nhập mới: $e");
      }
      return;
    }

    // Nếu đã có đợt nhập (bình thường)
    await saveMeasurement();
  }


  Future<DateTimeRange?> _showCustomDateRangeDialog(BuildContext context) async {
    // Khởi tạo với giá trị null
    DateTimeRange? _selectedRange;
    final now = DateTime.now();

    // Khởi tạo với ngày mặc định (hôm nay)
    final today = DateTime.now();
    final initialSelectedRange = DateTimeRange(
      start: today,
      end: today,
    );

    return showDialog<DateTimeRange?>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'CHỌN KHOẢNG THỜI GIAN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(height: 1),
                Expanded(
                  child: SfDateRangePicker(
                    view: DateRangePickerView.month,
                    selectionMode: DateRangePickerSelectionMode.range,
                    minDate: now.subtract(Duration(days: 365)),
                    maxDate: now.add(Duration(days: 365)),
                    initialSelectedRange: PickerDateRange(
                      today, // Ngày bắt đầu mặc định
                      today, // Ngày kết thúc mặc định
                    ),
                    monthViewSettings: DateRangePickerMonthViewSettings(
                      showTrailingAndLeadingDates: false,
                    ),
                    onSelectionChanged: (args) {
                      if (args.value is PickerDateRange &&
                          args.value.startDate != null &&
                          args.value.endDate != null) {
                        _selectedRange = DateTimeRange(
                          start: args.value.startDate!,
                          end: args.value.endDate ?? args.value.startDate!, // Đảm bảo endDate không null
                        );
                      }
                    },
                  ),
                ),
                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('HỦY BỎ'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Đảm bảo có giá trị mặc định nếu người dùng không chọn
                          final rangeToReturn = _selectedRange ?? initialSelectedRange;
                          Navigator.pop(context, rangeToReturn);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.stateGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'XÁC NHẬN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }













}

class ChangedValue {
  final double oldValue;
  final double newValue;
  ChangedValue({required this.oldValue, required this.newValue});
}

