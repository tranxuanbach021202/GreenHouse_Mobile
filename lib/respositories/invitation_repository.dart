import 'package:dio/dio.dart';

import '../network_service/api_service.dart';
import '../network_service/app_exception.dart';
import '../network_service/network_url/app_network_urls.dart';

class InvitationRepository {
  final ApiService _apiService;
  InvitationRepository(this._apiService);
  Future<dynamic> getInvitationsForUser()  async {
    try {
      final response = await _apiService.callGetApiResponse(
          url: AppNetworkUrls.invitations,);
      return response;
    } on DioException catch (e) {
      final apiException = ApiException.fromDioError(e);
      throw apiException;
    }
  }


  Future<void> acceptInvitation(String invitationId) async {
    try {
      await _apiService.callPostApiResponse(
        url: '${AppNetworkUrls.invitations}/$invitationId/accept',
        body: {'username': "tr"},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> rejectInvitation(String invitationId) async {
    try {
      await _apiService.callPostApiResponse(
        url: '${AppNetworkUrls.invitations}/$invitationId/reject', body: null,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

}
