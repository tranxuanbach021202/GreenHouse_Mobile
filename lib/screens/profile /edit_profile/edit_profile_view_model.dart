import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:greenhouse/base/viewmodels/base_view_model.dart';
import 'package:greenhouse/respositories/cloud_repository.dart';
import 'package:greenhouse/respositories/user_repository.dart';

import '../../../core/contants.dart';
import '../../../models/response/api_response.dart';
import '../../../models/response/presigned_upload_response.dart';
import '../../../models/user_model.dart';
import '../../../utils/logger.dart';

class EditProfileViewModel extends BaseViewModel{
  final CloudRepository _cloudRepository;
  final UserRepository _userRepository;
  EditProfileViewModel({
    required CloudRepository cloudRepository,
    required UserRepository userRepository
  })  : _cloudRepository = cloudRepository,
        _userRepository = userRepository;
  String? objectKey;
  String? presignedUrl;



  String? name;
  String? displayName;
  String? bio;
  String? email;
  File? avatarFile;
  String? urlAvatar;

  void initWithUser(User user) {
    name = user.username;
    displayName = user.displayName;
    email = user.email;
    urlAvatar = (user.urlAvatar ?? '').isNotEmpty ? user.urlAvatar : null;
    bio = user.bio;
    notifyListeners();
  }


  bool isLoading = false;

  void updateName(String value) {
    name = value;
    notifyListeners();
  }

  void updateBio(String value) {
    bio = value;
    notifyListeners();
  }

  void updateAvatar(File file) {
    avatarFile = file;
    notifyListeners();
  }

  Future<void> saveProfile() async {
    isLoading = true;
    if(avatarFile != null) {
      logger.i("Profile update" + avatarFile!.path.toString());
    }
    logger.i("Profile update" + name! + bio!);
    notifyListeners();

    try {
      if (avatarFile != null) {
        if (presignedUrl != null) {
          await _cloudRepository.uploadFile(
            presignedUrl: presignedUrl!,
            file: avatarFile!,
            contentType: 'image/jpeg',
          );
          urlAvatar = Constants.cloudStorageSubdomain + "/" +  objectKey!;
        }
      }
      if(urlAvatar == null) {
        urlAvatar = '';
      }
      await _userRepository.updateProfile(name!, urlAvatar!, bio!);

    } catch (e) {
      logger.e('Lỗi khi lưu thông tin: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }



  Future<void> getPresignedUrl() async {
    try {
      final data = {
        "contentType": "image/jpeg",
        "expirationTime": 3600,
        "folder": "profile",
      };
      final response = await _cloudRepository.getUploadUrl(data: data);
      final apiResponse = ApiResponse<PresignedUploadResponse>.fromJson(
        response as Map<String, dynamic>,
            (data) => PresignedUploadResponse.fromJson(data as Map<String, dynamic>),
      );

      objectKey = apiResponse.data.objectKey;
      presignedUrl = apiResponse.data.presignedUrl;
      notifyListeners();
    } catch (e) {
      logger.e("Lỗi get url: $e");
    }
  }

  @override
  FutureOr<void> init() {
      getPresignedUrl();
  }
}
