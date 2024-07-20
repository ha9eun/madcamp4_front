import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService apiService;
  final SecureStorageService secureStorageService;

  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  LoginViewModel({
    required this.apiService,
    required this.secureStorageService,
  });

  Future<void> login(String username, String password) async {
    try {
      final response = await apiService.login(username, password);
      String userId = response['_id'];

      // 사용자 정보 생성 및 Secure Storage에 저장
      _user = User.fromJson(response);
      await secureStorageService.writeSecureData('user_id', userId);

      _isLoggedIn = true;
      notifyListeners();

      print('로그인 성공: ${userId}');
    } catch (e) {
      print('로그인 실패: $e');
    }
  }

  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    String? userId = await secureStorageService.readSecureData('user_id');
    if (userId != null) {
      // 저장된 사용자 ID가 있는 경우 사용자 정보 불러오기
      try {
        final response = await apiService.getUserInfo(userId);
        _user = User.fromJson(response);
        _isLoggedIn = true;
      } catch (e) {
        print('사용자 정보 불러오기 실패: $e');
        _isLoggedIn = false;
      }
    } else {
      _isLoggedIn = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCoupleId(String coupleId) async {
    if (_user != null) {
      try {
        await apiService.updateCoupleId(_user!.id, coupleId);
        _user = User(
          id: _user!.id,
          username: _user!.username,
          nickname: _user!.nickname,
          coupleId: coupleId,
        );
        notifyListeners();
      } catch (e) {
        print('커플 ID 업데이트 실패: $e');
      }
    }
  }

  Future<void> logout() async {
    await secureStorageService.deleteSecureData('user_id');
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
