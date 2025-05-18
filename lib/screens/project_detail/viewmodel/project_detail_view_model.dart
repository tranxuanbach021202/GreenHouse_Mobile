import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/base/viewmodels/base_view_model.dart';
import 'package:greenhouse/models/response/project_member_response.dart';
import 'package:greenhouse/models/response/project_response.dart';
import 'package:greenhouse/respositories/project_repository.dart';
import 'package:greenhouse/utils/logger.dart';

import '../../../base/services/storage_service.dart';
import '../../../models/response/api_response.dart';
import '../../../models/response/measurement_response.dart';
import '../../../network_service/app_exception.dart';
import '../../../respositories/measurement_repository.dart';

class ProjectDetailViewModel extends BaseViewModel {
  // MARK: - Dependencies
  final ProjectRepository _projectRepository;
  final MeasurementRepository _measurementRepository;
  final StorageService _storageService;
  final String _projectId;

  // MARK: - State
  bool isLoading = true;
  String? errorMessage;
  ProjectResponse? project;
  List<MeasurementResponse> measurementList = [];
  bool isMeasurementFetched = false;

  // MARK: - UI State
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  // MARK: - User Information
  ProjectMemberResponse? owner;
  String? _currentUserId;
  bool get isOwner => owner?.userId == _currentUserId;

  // MARK: - Constructor
  ProjectDetailViewModel({
    required String projectId,
    required ProjectRepository projectRepository,
    required MeasurementRepository measurementRepository,
    required StorageService storageService,
  })  : _projectId = projectId,
        _projectRepository = projectRepository,
        _measurementRepository = measurementRepository,
        _storageService = storageService {
    init();
  }

  // MARK: - Initialization
  @override
  FutureOr<void> init() async {
    try {
      await _initCurrentUser();
      await fetchProjectDetail();
      await fetchMeasurementList();
    } catch (e) {
      setError(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initCurrentUser() async {
    _currentUserId = _storageService.getCurrentUserId();
  }

  // MARK: - Data Fetching
  Future<void> fetchProjectDetail() async {
    try {
      final response = await _projectRepository.getProjectDetail(_projectId);
      final apiResponse = ApiResponse<ProjectResponse>.fromJson(
        response as Map<String, dynamic>,
        (data) => ProjectResponse.fromJson(data),
      );

      project = apiResponse.data;


      logger.i("Project details loaded: ${project?.id}");

      owner = project?.members.firstWhere(
        (member) => member.role.toUpperCase() == 'OWNER',
        orElse: () => ProjectMemberResponse(
          userId: '',
          userName: '',
          email: '',
          displayName: '',
          urlAvatar: '',
          role: '',
        ),
      );
    } catch (e) {
      logger.e("Error fetching project detail: $e");
      throw "Failed to load project details: ${e.toString()}";
    }
  }

  Future<void> fetchMeasurementList() async {
    try {
      final response = await _measurementRepository.getMeasurement(_projectId);
      final apiResponse = ApiResponse<List<MeasurementResponse>>.fromJson(
        response as Map<String, dynamic>,
        (data) => (data as List).map((e) => MeasurementResponse.fromJson(e)).toList(),
      );

      measurementList = apiResponse.data;
      isMeasurementFetched = true;
      logger.i("Measurements loaded: ${measurementList.length}");

      notifyListeners();
    } catch (e) {
      logger.e("Error fetching measurements: $e");
      throw "Failed to load measurements: ${e.toString()}";
    }
  }

  // MARK: - UI Actions
  void setTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  Future<void> reload() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await fetchProjectDetail();
      await fetchMeasurementList();
    } catch (e) {
      setError(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // MARK: - Operation Methods
  Future<bool> updateProjectPublicStatus(BuildContext context, String projectId, bool newStatus) async {
    try {
      logger.i('Updating project public status to: $newStatus');
      await _projectRepository.updatePublicStatus(projectId, newStatus);
      project?.isPublic = newStatus;
      notifyListeners();

      _showMessage(
        context,
        newStatus ? 'Dự án đã được công khai' : 'Dự án đã chuyển sang chế độ riêng tư',
        isError: false
      );
      return true;
    } catch (e) {
      logger.e("Error updating project public status: $e");
      _showMessage(context, 'Cập nhật thất bại. Vui lòng thử lại.', isError: true);
      return false;
    }
  }

  Future<void> deleteMeasurementById(String id) async {
    try {
      await _measurementRepository.deleteMeasurement(id);
      measurementList.removeWhere((element) => element.id == id);
      notifyListeners();
    } on ApiException catch (e) {
      setError(e.message ?? 'Xảy ra lỗi khi xoá');
    } catch (e) {
      setError('Xảy ra lỗi không xác định khi xoá');
    }
  }

  Future<bool> generateAndSaveQrPdf(
      BuildContext context,
      String projectId,
      String urlApp,
      String projectCode,
      ) async {
    try {

      final rawBytes = await _projectRepository.generateQrLayout(projectId, urlApp);
      final bytes = Uint8List.fromList(rawBytes);

      // Lưu file và chờ kết quả trả về đường dẫn
      final String? result = await FileSaver.instance.saveAs(
        name: 'layout_qr_$projectCode.pdf',
        bytes: bytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );

      if (result != null && result.isNotEmpty) {
        _showMessage(context, 'Đã lưu QR PDF tại: $result', isError: false);
        return true;
      } else {
        _showMessage(context, 'Không thể lưu file.', isError: true);
        return false;
      }
    } catch (e) {
      _showMessage(context, 'Lỗi tạo QR PDF: $e', isError: true);
      return false;
    }
  }

  Future<bool> exportMeasurementToExcel(
      BuildContext context,
      String projectId,
      ) async {
    try {
      // Gọi API lấy dữ liệu file Excel dạng byte[]
      final rawBytes = await _measurementRepository.exportMeasurementData(projectId);
      final bytes = Uint8List.fromList(rawBytes);

      // Mở dialog lưu file
      final String? result = await FileSaver.instance.saveAs(
        name: 'measurement_$projectId.xlsx',
        bytes: bytes,
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );

      if (result != null && result.isNotEmpty) {
        _showMessage(context, '✅ Đã lưu file Excel tại: $result', isError: false);
        return true;
      } else {
        _showMessage(context, '❌ Không thể lưu file.', isError: true);
        return false;
      }
    } catch (e) {
      logger.i("Error: $e");
      _showMessage(context, '❌ Xuất dữ liệu thất bại: $e', isError: true);
      return false;
    }
  }

  Future<void> deleteProject(String projectId, BuildContext context) async {
    isLoading = true;
    clearError();

    try {
      await _projectRepository.deleteProject(projectId);

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Xoá dự án thành công'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      context.go('/project_management');
    } catch (e) {
      setError('Xoá dự án thất bại. Vui lòng thử lại sau.');
    } finally {
      isLoading = false;
    }
  }




  // MARK: - Helpers
  void setError(String message) {
    errorMessage = message;
    isLoading = false;
    notifyListeners();
  }

  void _showMessage(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
