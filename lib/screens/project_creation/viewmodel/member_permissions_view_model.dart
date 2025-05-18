import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:greenhouse/respositories/project_repository.dart';
import 'package:provider/provider.dart';
import '../../../base/services/storage_service.dart';
import '../../../base/viewmodels/base_view_model.dart';
import '../../../models/enums/project_role.dart';
import '../../../models/project_member.dart';
import '../../../models/request/update_project_member_request.dart';
import '../../../models/response/api_response.dart';
import '../../../models/user_model.dart';
import '../../../respositories/user_repository.dart';
import '../../../utils/logger.dart';
import '../project_setup_provider.dart';


class MemberPermissionsViewModel extends BaseViewModel {
  final UserRepository _userRepository;
  final StorageService _storageService;
  final ProjectSetupProvider _projectSetupProvider;
  final ProjectRepository _projectRepository;


  MemberPermissionsViewModel({
    required UserRepository userRepository,
    required StorageService storageService,
    required ProjectSetupProvider projectSetupProvider,
    required ProjectRepository projectRepository,
  })  : _userRepository = userRepository,
        _storageService = storageService,
        _projectSetupProvider = projectSetupProvider,
        _projectRepository = projectRepository;

  final _searchController = TextEditingController();

  // State variables
  List<User> _searchResults = [];
  User? _currentUser;
  List<ProjectMember> _selectedMembers = [];
  List<ProjectMember> _projectMembers = [];
  List<ProjectMember> _addedMembers = [];
  Map<String, ProjectRole> _tempUserRoles = {};

  List<ProjectMember> get displayMembers {
    return [..._projectMembers, ..._addedMembers];
  }

  List<String> _removedUserIds = [];

  String _searchQuery = '';
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  // Error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Getters
  List<User> get searchResults => _searchResults;
  User? get currentUser => _currentUser;
  List<ProjectMember> get selectedMembers => _selectedMembers;
  List<ProjectMember> get projectMembers => _projectMembers;
  bool get hasMore => _hasMore;



  @override
  FutureOr<void> init() async {
    _searchResults = [];
    _currentUser = null;
    _selectedMembers = [];
    _searchQuery = '';
    _currentPage = 0;
    _hasMore = true;
    _errorMessage = null;
    loadCurrentUser();
    _projectMembers.add(
        ProjectMember(
            userId: currentUser!.id,
            email: currentUser!.email,
            name: currentUser!.username,
            urlAvatar: currentUser!.urlAvatar,
            role: ProjectRole.OWNER)
    );
  }

  void setInitialMembers(List<ProjectMember> members) {
    _projectMembers = [...members];
    _addedMembers.clear();
    _removedUserIds.clear();
    notifyListeners();
  }


  void loadCurrentUser() {
    final userData = _storageService.getUserData();
    logger.i("load user current");

    if (userData == null) {
      logger.e("Không tìm thấy thông tin user trong StorageService");
      return;
    }

    try {
      logger.i("Load user current data: $userData");
      _currentUser = User.fromJson(userData);
      reloadState();
    } catch (e) {
      logger.e("Lỗi khi parse user từ JSON: $e");
      setError("Không thể tải thông tin người dùng");
    }
  }

  Future<void> searchUsers({bool refresh = false, String? search}) async {
    if (isLoading) return;

    if (refresh) {
      _searchResults.clear();
      _currentPage = 0;
      _hasMore = true;
    }
    if (!_hasMore) return;
    try {
      isLoading = true;
      clearError();
      logger.i("Add member viewmodel - Searching users");

      final response = await _userRepository.searchUsers(
        page: _currentPage,
        size: 10,
        sortBy: 'name',
        sortDir: 'asc',
        search: search,
      );

      final apiResponse = ApiResponse<List<User>>.fromJson(
        response as Map<String, dynamic>,
            (dynamic data) {
          final List<dynamic> list = data as List;
          return list.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
        },
      );

      // Lọc ra những người dùng không có trong danh sách hiển thị hiện tại
      if (refresh) {
        _searchResults = apiResponse.data.where((user) =>
        !isUserAdded(user.id)
        ).toList();
      } else {
        _searchResults.addAll(apiResponse.data.where((user) =>
        !isUserAdded(user.id)
        ).toList());
      }

      _currentPage++;

    } catch (e) {
      logger.e("Lỗi: $e");
      setError('Có lỗi xảy ra khi tải danh sách người dùng');
    } finally {
      isLoading = false;
    }
  }


  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    searchUsers(refresh: true, search: query);
  }

  void toggleUserSelection(User user, ProjectRole role) {
    final index = _selectedMembers.indexWhere((member) => member.userId == user.id);

    if (index == -1) {
      // Thêm thành viên mới
      _selectedMembers.add(ProjectMember(
        userId: user.id,
        email: user.email,
        name: user.username,
        urlAvatar: user.urlAvatar,
        role: role,
      ));
    } else {
      _selectedMembers[index] = ProjectMember(
        userId: user.id,
        email: user.email,
        name: user.username,
        urlAvatar: user.urlAvatar,
        role: role,
      );
    }
    reloadState();
  }

  void updateUserRole(String userId, ProjectRole newRole) {
    _tempUserRoles[userId] = newRole;

    logger.i("Da them role vao:" + newRole.toString());
    notifyListeners();
  }

  ProjectRole? getUserRole(String userId) {
    return _tempUserRoles[userId];
  }

  void addMember(User user) {
    final existingInDisplay = displayMembers.any((e) => e.userId == user.id);
    if (existingInDisplay) return;

    // Tạo đối tượng thành viên mới
    final member = ProjectMember(
      userId: user.id,
      email: user.email,
      name: user.username,
      urlAvatar: user.urlAvatar,
      role: _tempUserRoles[user.id] ?? ProjectRole.GUEST,
    );

    // Kiểm tra xem đây có phải là thành viên cũ đã bị xóa không
    final wasRemoved = _removedUserIds.contains(user.id);
    if (wasRemoved) {
      // Nếu là thành viên cũ đã bị xóa, thêm lại vào _projectMembers và xóa khỏi _removedUserIds
      _projectMembers.add(member);
      _removedUserIds.remove(user.id);
    } else {
      // Kiểm tra xem đây có phải là thành viên cũ chưa
      final existingInOriginal = _projectMembers.any((e) => e.userId == user.id);
      if (!existingInOriginal) {
        // Nếu là người mới hoàn toàn, thêm vào danh sách thêm mới
        _addedMembers.add(member);
      }
    }

    notifyListeners();
  }



  void removeMember(String userId) {

    final isNewlyAdded = _addedMembers.any((member) => member.userId == userId);


    if (isNewlyAdded) {
      // Nếu là thành viên mới thêm, chỉ cần xóa khỏi danh sách thêm mới
      _addedMembers.removeWhere((member) => member.userId == userId);
    } else {
      // Nếu là thành viên cũ, thêm vào danh sách xóa và xóa khỏi _projectMembers
      if (!_removedUserIds.contains(userId)) {
        _removedUserIds.add(userId);
      }
      _projectMembers.removeWhere((member) => member.userId == userId);
    }

    _tempUserRoles.remove(userId);
    reloadState();
  }



  bool isUserAdded(String userId) {
    return _projectMembers.any((member) => member.userId == userId) ||
        _addedMembers.any((member) => member.userId == userId);
  }


  String getProjectCode() {
    return _projectSetupProvider.code!;
  }

  ProjectMember? getMemberById(String userId) {
    try {
      // Tìm trong danh sách thành viên cũ
      final oldMember = _projectMembers.firstWhere(
            (member) => member.userId == userId,
        orElse: () => throw Exception(),
      );
      return oldMember;
    } catch (e) {
      try {
        // Tìm trong danh sách thành viên mới
        final newMember = _addedMembers.firstWhere(
              (member) => member.userId == userId,
          orElse: () => throw Exception(),
        );
        return newMember;
      } catch (e) {
        return null;
      }
    }
  }





  void removeMemberResult(String userId) {
    _searchResults.removeWhere((member) => member.id == userId);
    reloadState();
  }

  void clearSelection() {
    _selectedMembers.clear();
    reloadState();
  }

  Future<bool> saveMemberPermissions({bool isEditMode = false, String? projectId}) async {
    try {
      isLoading = true;

      if (isEditMode && projectId != null) {
        List<MemberUpdateItem> updates = [];

        for (String userId in _removedUserIds) {
          updates.add(MemberUpdateItem(
            userId: userId,
            role: "",
            remove: true,
          ));
        }

        for (ProjectMember member in _projectMembers) {
          if (!_removedUserIds.contains(member.userId)) {
            updates.add(MemberUpdateItem(
              userId: member.userId,
              role: member.role.toString().split('.').last,
              remove: false,
            ));
          }
        }


        List<MemberInviteItem> invites = _addedMembers.map((member) =>
            MemberInviteItem(
              userId: member.userId,
              email: member.email,
              name: member.name!,
              role: member.role.toString().split('.').last,
            )
        ).toList();


        final request = UpdateProjectMembersRequest(
          updates: updates,
          invites: invites,
        );

        await _projectRepository.updateProjectMembers(
          projectId,
          request,
        );



      } else {
        // Chế độ tạo mới: Chỉ cập nhật danh sách thành viên trong provider
        // Không gọi API, vì thành viên sẽ được gửi khi tạo dự án mới
        _projectSetupProvider.setMembers([..._projectMembers, ..._addedMembers]);
      }

      return true;
    } catch (e) {
      setError('Có lỗi xảy ra khi lưu thông tin');
      return false;
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _projectMembers.clear();
    _addedMembers.clear();
    _tempUserRoles.clear();
    _removedUserIds.clear();
    _searchResults.clear();
    _searchQuery = '';
    super.dispose();
  }



}

