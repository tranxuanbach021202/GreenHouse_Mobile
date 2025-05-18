import 'package:flutter/foundation.dart';

import '../../../models/invitation_model.dart';
import '../../../network_service/app_exception.dart';
import '../../../respositories/invitation_repository.dart';


class InvitationViewModel extends ChangeNotifier {
  final InvitationRepository _invitationRepository;

  InvitationViewModel(this._invitationRepository);

  List<InvitationModel> _invitations = [];
  bool _isLoading = false;
  String? _error;

  List<InvitationModel> get invitations => _invitations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchInvitations() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _invitationRepository.getInvitationsForUser();
      _invitations = (data as List)
          .map((json) => InvitationModel.fromJson(json))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> acceptInvitation(String id) async {
    try {
      await _invitationRepository.acceptInvitation(id);
      invitations.removeWhere((e) => e.id == id);
      notifyListeners();
    }  on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> rejectInvitation(String id) async {
    try {
      await _invitationRepository.rejectInvitation(id);
      invitations.removeWhere((e) => e.id == id);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
