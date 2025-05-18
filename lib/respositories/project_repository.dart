

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:greenhouse/models/project.dart';
import 'package:greenhouse/models/request/project_update_request.dart';
import 'package:greenhouse/utils/logger.dart';

import '../models/request/update__factor_and_criterion_request.dart';
import '../models/request/update_project_member_request.dart';
import '../network_service/api_service.dart';
import '../network_service/app_exception.dart';
import '../network_service/network_url/app_network_urls.dart';

class ProjectRepository {
  final ApiService _apiService;
  ProjectRepository(this._apiService);

  Future<dynamic> createProject(Project project) async {
    try {
      final response = await _apiService.callPostApiResponse(
        url: AppNetworkUrls.createProject,
        body: jsonEncode({
            'projectCode':project.code,
            'projectName': project.name,
            'startDate': project.startDate?.toIso8601String(),
            'endDate': project.endDate?.toIso8601String(),
            'thumbnailUrl': project.thumbnailUrl,
            'description': project.description,
            'thumbnailUrl': project.thumbnailUrl,
            'experimentType': project.experimentType.toString().split('.').last,
            'members': project.members.map((member) => member.toJson()).toList(),
            'factor': project.factor.toJson(),
            'criteria': project.criteria.map((criterion) => criterion.toJson()).toList(),
            'blocks': project.blocks,
            'replicates': project.replicates,
            'columns': project.columns,
            'layout': project.layout,
        }),
      );

      logger.i("Tạo project thành công");

      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }

  }

  Future<dynamic> getProjectsUser() async {
    try {
      final response = await _apiService.callGetApiResponse(
        url: AppNetworkUrls.getProjectUser,
      );

      logger.i(response.toString());
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }

  Future<dynamic> getProjectsAsMemberOrGuest() async {
    try {
      final response = await _apiService.callGetApiResponse(
        url: AppNetworkUrls.project + '/member-or-guest',
      );

      logger.i(response.toString());
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }

  Future<dynamic> getPublicProjects() async {
    try {
      final response = await _apiService.callGetApiResponse(
        url: AppNetworkUrls.project + '/public',
      );

      logger.i(response.toString());
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }

  Future<dynamic> searchProjects({
    String? keyword,
    int page = 0,
    int size = 10,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    final queryParams = {
      'keyword': keyword ?? '',
      'page': '$page',
      'size': '$size',
      'sortBy': sortBy,
      'sortDir': sortDir,
    };

    try {
      final response = await _apiService.callGetApiResponse(
        url: AppNetworkUrls.project + '/search',
        parameters: queryParams,
      );

      logger.i(response.toString());
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }



  Future<dynamic> getProjectDetail(String projectId) async {
    try {
      final response = await _apiService.callGetApiResponse(
        url: AppNetworkUrls.project + '/' + projectId,
      );
      logger.i(response.toString());
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }


  Future<List<int>> generateQrLayout(String projectId, String urlApp) async {
    try {
      final response = await _apiService.callPostApiResponse(
        url: AppNetworkUrls.exQrCode,
        body: jsonEncode({
          'projectId': projectId,
          'urlApp': urlApp,
        }),
        options: Options(responseType: ResponseType.bytes),
      );
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }





  Future<void> deleteProject(String projectId) async {
    try {
      await _apiService.callDeleteApiResponse(
        url: AppNetworkUrls.project + '/' + projectId,
        body: null
      );
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }


  Future<void> updatePublicStatus(String projectId, bool isPublic) async {
    try {
      final body = jsonEncode({'isPublic': isPublic});
      logger.i("update ispublic :" + body.toString());
      final response = await _apiService.callPutApiResponse(
        url: AppNetworkUrls.project + '/' + projectId + '/visibility',
        body: body,
      );
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }


  @override
  Future<void> updateProject(String id, ProjectUpdateRequest request) async {
    try {
      final response = await _apiService.callPutApiResponse(
        url: AppNetworkUrls.project + '/${id}' ,
        body: request.toJson(),
      );
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }


  Future<void> updateProjectMembers(String projectId, UpdateProjectMembersRequest request) async {
    try {
      final response = await _apiService.callPutApiResponse(
        url: AppNetworkUrls.project + "/${projectId}/members",
        body: request.toJson(),
      );

      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }

  Future<void> updateFactorAndCriteria(String projectId, Map<String, dynamic> body) async {
    try {

      final response = await _apiService.callPutApiResponse(
        url: "${AppNetworkUrls.project}/${projectId}/factor-and-criteria",
        body: body,
      );

      logger.i("Cập nhật thành công Factor & Criteria");
    } catch (e) {
      logger.e("Lỗi khi cập nhật factor & criteria: $e");
      rethrow;
    }
  }




}