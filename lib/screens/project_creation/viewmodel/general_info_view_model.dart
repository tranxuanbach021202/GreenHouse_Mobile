// lib/features/project_creation/viewmodels/general_info_viewmodel.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:greenhouse/models/response/api_response.dart';
import 'package:greenhouse/respositories/cloud_repository.dart';
import 'package:greenhouse/utils/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../base/viewmodels/base_view_model.dart';
import '../../../core/contants.dart';
import '../../../models/request/project_update_request.dart';
import '../../../models/response/presigned_upload_response.dart';
import '../../../models/response/project_response.dart';
import '../../../network_service/app_exception.dart';
import '../../../respositories/project_repository.dart';
import '../project_setup_provider.dart';


class GeneralInfoViewModel extends BaseViewModel {
  final formKey = GlobalKey<FormState>();
  final TextEditingController projectIdController = TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _imageFile;
  String? _thumbnailUrl;

  // Getters
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  File? get imageFile => _imageFile != null ? File(_imageFile!) : null;
  String? get thumbnailUrl => _thumbnailUrl;



  final ProjectSetupProvider? _projectSetupProvider;
  final ProjectRepository? _projectRepository;
  final CloudRepository _cloudRepository;
  final bool isEditMode;

  GeneralInfoViewModel._({
    required CloudRepository cloudRepository,
    ProjectSetupProvider? projectSetupProvider,
    ProjectRepository? projectRepository,
    required this.isEditMode,
  })  : _cloudRepository = cloudRepository,
        _projectSetupProvider = projectSetupProvider,
        _projectRepository = projectRepository;

  factory GeneralInfoViewModel.forCreate({
    required ProjectSetupProvider setupProvider,
    required CloudRepository cloudRepository,
  }) {
    return GeneralInfoViewModel._(
      projectSetupProvider: setupProvider,
      cloudRepository: cloudRepository,
      isEditMode: false,
    );
  }

  factory GeneralInfoViewModel.forEdit({
    required ProjectRepository projectRepository,
    required CloudRepository cloudRepository,
  }) {
    return GeneralInfoViewModel._(
      projectRepository: projectRepository,
      cloudRepository: cloudRepository,
      isEditMode: true,
    );
  }


  @override
  FutureOr<void> init() async {
  }

  bool get isFormValid {
    return projectIdController.text.isNotEmpty &&
        projectNameController.text.isNotEmpty &&
        _startDate != null &&
        _endDate != null;
  }


  Future<void> selectStartDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
        reloadState();
      }
    } catch (e) {
      setError('Không thể chọn ngày bắt đầu');
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    try {
      if (_startDate == null) {
        setError('Vui lòng chọn ngày bắt đầu trước');
        return;
      }

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _startDate!.add(const Duration(days: 1)),
        firstDate: _startDate!.add(const Duration(days: 1)),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        _endDate = picked;
        reloadState();
      }
    } catch (e) {
      setError('Không thể chọn ngày kết thúc');
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      isLoading = true;
      notifyListeners();

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        logger.i("pick image 1");
        _imageFile = image.path;
        logger.i("pick image path" + _imageFile.toString());
        notifyListeners();
      }
    } catch (e) {
      print('Error picking image: $e');
      setError('Không thể chọn ảnh. Vui lòng thử lại');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<bool> saveGeneralInfo() async {
  //   try {
  //     isLoading = true;
  //     // if (!isFormValid) {
  //     //   setError('Vui lòng điền đầy đủ thông tin bắt buộc');
  //     //   return false;
  //     // }
  //
  //     _projectSetupProvider?.setBasicInfo(
  //       code: projectIdController.text,
  //       name: projectNameController.text,
  //       startDate: _startDate!,
  //       endDate: _endDate!,
  //       description: descriptionController.text.isNotEmpty
  //           ? descriptionController.text
  //           : null,
  //       imageFile: _imageFile ?? '',
  //     );
  //     logger.i("save info project");
  //     return true;
  //   } catch (e) {
  //     setError('Có lỗi xảy ra khi lưu thông tin');
  //     logger.i("Lỗi lưu thông tin");
  //     return false;
  //   } finally {
  //     isLoading = false;
  //   }
  // }


  // Future<void> updateProject(String projectId, ProjectUpdateRequest request) async {
  //   try {
  //     // show loading if needed
  //     await _projectRepository?.updateProject(projectId, request);
  //     // show success toast or navigate
  //   } catch (e) {
  //     // handle error, show snackbar or dialog
  //     debugPrint('Error updating project: $e');
  //   }
  // }


  bool _isUpdated = false;
  bool get isUpdated => _isUpdated;

  Future<bool> submit({required bool isEditMode,
    String? projectId,
    required BuildContext context,}) async {
    try {
      isLoading = true;

      // if (!isFormValid) {
      //   setError('Vui lòng điền đầy đủ thông tin bắt buộc');
      //   return false;
      // }

      if (isEditMode) {

        if (_imageFile != null) {
          await getPresignedUrl();
          await uploadImage();
          _thumbnailUrl = objectKey != null
              ? Constants.cloudStorageSubdomain + '/' + objectKey!
              : _thumbnailUrl;
        }

        await Future.delayed(const Duration(seconds: 1));

        final request = ProjectUpdateRequest(
          projectName: projectIdController.text,
          projectCode: projectNameController.text,
          startDate: _startDate!,
          endDate: _endDate!,
          description: descriptionController.text.isNotEmpty
              ? descriptionController.text
              : null,
          thumbnailUrl: _thumbnailUrl!,
        );
        await _projectRepository!.updateProject(projectId!, request);
        _isUpdated = true;
        return true;
      } else {
        _projectSetupProvider!.setBasicInfo(
          code: projectIdController.text,
          name: projectNameController.text,
          startDate: _startDate!,
          endDate: _endDate!,
          description: descriptionController.text.isNotEmpty
              ? descriptionController.text
              : null,
          imageFile: _imageFile ?? '',
        );
        return true;
      }
    } on ApiException catch (e) {
      switch (e.type) {
        case ApiErrorType.duplicateProjectCode:
          setError('Mã code dự án trùng với dự án khác.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Mã code dự án trùng với dự án khác.',
                style: TextStyle(color: Colors.red),
              ),
              backgroundColor: Colors.green.shade100,
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
        default:
          setError('Đã có lỗi xảy ra. Vui lòng thử lại sau.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Đã có lỗi xảy ra. Vui lòng thử lại sau.',
                style: TextStyle(color: Colors.red),
              ),
              backgroundColor: Colors.green.shade100,
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
      }
      return false;
    } finally {
      isLoading = false;
    }
  }

  // upload image to cloud
  String? presignedUrl;
  String? objectKey;


  Future<void> getPresignedUrl() async {
    try {
      final data = {
        "contentType": "image/jpeg",
        "expirationTime": 3600,
        "folder": "project",
      };
      final response = await _cloudRepository.getUploadUrl(data: data);
      final apiResponse = ApiResponse<PresignedUploadResponse>.fromJson(
        response as Map<String, dynamic>,
            (data) => PresignedUploadResponse.fromJson(data as Map<String, dynamic>),
      );

      logger.i("get url" +apiResponse.data.objectKey);
      objectKey = apiResponse.data.objectKey;
      presignedUrl = apiResponse.data.presignedUrl;
      notifyListeners();
    } catch (e) {
      logger.e("Lỗi get url: $e");
    }
  }


  Future<void> uploadImage() async {
    try {
      if (presignedUrl == null) return;
      final file = File(_imageFile!);
      final success = await _cloudRepository.uploadFile(
        presignedUrl: presignedUrl!,
        file: file,
        contentType: 'image/jpeg',
      );
      if (success) {
        print('✅ Upload thành công');
      } else {
        print('❌ Upload thất bại');
      }

    } catch (e) {
      logger.e("Lỗi upload file");
    }
  }




  void clearData() {
    projectIdController.clear();
    projectNameController.clear();
    descriptionController.clear();
    _startDate = null;
    _endDate = null;
    _imageFile = null;
    clearError();
    reloadState();
  }



  void prefillDataFromProject(ProjectResponse project) {
    projectIdController.text = project.code;
    projectNameController.text = project.name;
    descriptionController.text = project.description;
    _startDate = project.startDate;
    _endDate = project.endDate;
    _thumbnailUrl = project.thumbnailUrl;
  }




  @override
  void dispose() {
    projectIdController.dispose();
    projectNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
