import 'dart:async';
import 'dart:io';

import 'package:greenhouse/base/viewmodels/base_view_model.dart';
import 'package:greenhouse/core/contants.dart';
import 'package:greenhouse/core/router/app_router.dart';
import 'package:greenhouse/models/enums/experiment_type.dart';
import 'package:greenhouse/respositories/cloud_repository.dart';
import 'package:greenhouse/respositories/project_repository.dart';
import 'package:image_picker/image_picker.dart';

import '../../base/services/navigation_service.dart';
import '../../base/services/success_screen_args.dart';
import '../../models/criterion_model.dart';
import '../../models/factor_model.dart';
import '../../models/project.dart';
import '../../models/project_member.dart';
import '../../models/response/api_response.dart';
import '../../models/response/presigned_upload_response.dart';
import '../../models/treatment.dart';
import '../../network_service/app_exception.dart';
import '../../utils/logger.dart';

class ProjectSetupProvider extends BaseViewModel {

  final NavigationService _navigationService;
  final ProjectRepository _projectRepository;
  final CloudRepository _cloudRepository;

  ProjectSetupProvider({
    required ProjectRepository projectRepository,
    required NavigationService navigationService,
    required CloudRepository cloudRepository,
  })  : _projectRepository = projectRepository,
        _navigationService = navigationService,
        _cloudRepository = cloudRepository;


  String? _code;
  String? _name;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _description;
  String? _imageFile;
  String? _thumbnailUrl;

  List<ProjectMember> _members = [];
  Factor? _factor;
  List<Criterion> _criterions = [];
  List<Treatment> _treatments = [];

  // Experiment Configuration
  ExperimentType _experimentType = ExperimentType.RCBD;
  int _blocks = 1;
  int _replicates = 1;
  int _columns = 2;
  List<List<String>> _layout = [];

  // Getters
  String? get code => _code;
  String? get name => _name;
  List<ProjectMember>? get members => _members;
  Factor? get factor => _factor;
  List<Treatment>? get treatments => _treatments;
  List<Criterion>? get criterions => _criterions;



  // Validation states
  bool get isBasicInfoValid => _code != null && _name != null && _startDate != null && _endDate != null;
  bool get isMembersValid => _members.isNotEmpty;
  bool get isFactorValid => _factor != null;
  bool get isCriterionsValid => _criterions.isNotEmpty;
  bool get isTreatmentsValid => _treatments.isNotEmpty;
  // bool get isExperimentConfigValid => _experimentConfig != null;

  bool get isReadyToCreate {
    return isBasicInfoValid &&
        isMembersValid &&
        isFactorValid &&
        isCriterionsValid &&
        isTreatmentsValid;
  }

  void setBasicInfo({
    required String code,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
    String? imageFile
  }) {
    _code = code;
    _name = name;
    _startDate = startDate;
    _endDate = endDate;
    _description = description;
    _imageFile = imageFile;
    notifyListeners();
  }

  void setMembers(List<ProjectMember> members) {
    _members = members;
    notifyListeners();
  }

  void setFactor(Factor factor) {
    _factor = factor;

    // Set treatment từ levels của factor
    _treatments = factor.levels.map((level) {
      return Treatment(
        code: level.code,
        name: level.name,
      );
    }).toList();

    notifyListeners();
  }


  void setCriterion(List<Criterion> criterions) {
    logger.i("criter" + criterions.toString());
    _criterions = criterions;
    notifyListeners();
  }

  void setTreatments(List<Treatment> treatments) {
    _treatments = treatments;
    notifyListeners();
  }

  void setExperimentConfig({
    required ExperimentType experimentType,
    required int blocks,
    required int replicates,
    required int columns,
    required List<List<String>> layout,
  }) {
    _experimentType = experimentType;
    _blocks = blocks;
    _replicates = replicates;
    _columns = columns;
    _layout = layout;
    notifyListeners();
  }

  Project? _createProject() {
    return Project(
      code: _code!,
      name: _name!,
      startDate: _startDate!,
      endDate: _endDate!,
      description: _description,
      thumbnailUrl: _thumbnailUrl,
      members: _members.isNotEmpty ? _members : [],
      factor: _factor!,
      criteria: _criterions.isNotEmpty ? _criterions : [],
      treatments: _treatments.isNotEmpty ? _treatments : [],
      experimentType: _experimentType,
      blocks: _blocks,
      replicates: _replicates,
      columns: _columns,
      layout: _layout.isNotEmpty ? _layout : [],
    );
  }


  Future<void> createProject() async {
    try {
      isLoading = true;
      logger.i("url image" + _imageFile.toString());
      logger.i("factor" + _factor!.code.toString());
      if (_imageFile != null) {
        await uploadImage();
        _thumbnailUrl = Constants.cloudStorageSubdomain + "/" + objectKey!;
      } else {
        _thumbnailUrl = '';
      }
      final project = _createProject();
      final response = await _projectRepository.createProject(project!);
      _navigationService.go(
        '/success',
        extra: SuccessScreenArgs(
          title: 'Tạo dự án thành công!',
          message: 'Bạn sẽ được chuyển về trang chủ sau giây lát.',
          animationAsset: 'assets/animations/success.json',
          showButton: false,
          buttonText: '',
          onButtonPressed: () {},
          autoRedirectDelay: const Duration(seconds: 3),
          onAutoRedirect: () {
            _navigationService.go('/main_screen');
          },
        ),
      );


    } on ApiException catch (e) {
      logger.e("Lỗi API: ${e.message}");
      switch (e.type) {
        case ApiErrorType.wrongPassword:
          setError('Sai mật khẩu. Vui lòng kiểm tra lại.');
          break;
        case ApiErrorType.userNotFound:
          setError('Tài khoản không tồn tại. Vui lòng kiểm tra lại.');
          break;
        default:
          setError('Đã có lỗi xảy ra. Vui lòng thử lại sau.');
          break;
      }
    } finally {
      isLoading = false;
    }
  }



  // upload image to cloud
  String? presignedUrl;
  String? objectKey;

  // updaload anh
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

  Future<void> updateFactorCriteriaAndLayout({
    required String projectId,
    required Map<String, dynamic> body,
  }) async {
    try {
      logger.i("📤 Yêu cầu cập nhật yếu tố, chỉ tiêu và bố trí:\n${body}");
      final response = await _projectRepository.updateFactorAndCriteria(projectId,body);



      logger.i("✅ Đã cập nhật yếu tố, chỉ tiêu và bố trí thành công.");
    } catch (e) {
      logger.e("❌ Lỗi khi cập nhật yếu tố & bố trí: $e");
      rethrow;
    }
  }



  void reset() {
    _code = null;
    _name = null;
    _startDate = null;
    _endDate = null;
    _description = null;
    _members.clear();
    _factor = null;
    _criterions.clear();
    _treatments.clear();
    _experimentType = ExperimentType.RCBD;
    _blocks = 1;
    _replicates = 1;
    _columns = 2;
    _layout.clear();
    notifyListeners();
  }


  @override
  FutureOr<void> init() {
    getPresignedUrl();
  }
}
