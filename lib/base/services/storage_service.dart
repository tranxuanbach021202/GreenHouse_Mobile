import 'dart:convert';
import 'package:greenhouse/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../../models/response/auth_response.dart';
import '../../utils/logger.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _tokenTypeKey = 'token_type';

  static const String _introSeenKey = 'intro_seen';

  final SharedPreferences _prefs;
  StorageService(this._prefs);


  Future<bool> saveAuthData(AuthResponse authResponse) async {
    try {
      logger.i("true luu data");
      await Future.wait([
        _prefs.setString(_tokenKey, authResponse.token),
        _prefs.setString(_refreshTokenKey, authResponse.refreshToken),
        _prefs.setString(_tokenTypeKey, authResponse.type),
        _prefs.setString(_userDataKey, jsonEncode({
          'id': authResponse.id,
          'username': authResponse.username,
          'email': authResponse.email,
          'role': authResponse.role,
        })),
      ]);
      logger.i("true luu data");
      return true;
    } catch (e) {
      logger.i("e luu data");
      print('Error saving auth data: $e');
      return false;
    }
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  String getTokenType() {
    return _prefs.getString(_tokenTypeKey) ?? 'Bearer';
  }

  Map<String, dynamic>? getUserData() {
    final userStr = _prefs.getString(_userDataKey);
    if (userStr == null) return null;
    return jsonDecode(userStr) as Map<String, dynamic>;
  }

  String? getFullToken() {
    final type = getTokenType();
    final token = getToken();
    if (token == null) return null;
    return '$type $token';
  }

  String? getCurrentUserId() {
    final userData = getUserData();
    return userData?['id'] as String?;
  }

  String? getUsername() {
    return getUserData()?['username'] as String?;
  }



  Future<void> clearAuth() async {
    await Future.wait([
      _prefs.remove(_tokenKey),
      _prefs.remove(_refreshTokenKey),
      _prefs.remove(_tokenTypeKey),
      _prefs.remove(_userDataKey),
    ]);
  }

  Future<bool> setIntroSeen(bool seen) async {
    try {
      return await _prefs.setBool(_introSeenKey, seen);
    } catch (e) {
      logger.e("Error setting intro seen: $e");
      return false;
    }
  }

  Future<bool> isIntroSeen() async {
    return _prefs.getBool(_introSeenKey) ?? false;
  }

}

