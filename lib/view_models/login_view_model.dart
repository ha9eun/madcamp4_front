import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final SecureStorageService _secureStorageService = SecureStorageService();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  UserModel? _user;
  UserModel? get user => _user;

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final responseData = await _apiService.login(username, password);
      String token = responseData['token'];

      // 로그인 성공 시 Secure Storage에 토큰 저장
      await _secureStorageService.writeSecureData('token', token);

      // 사용자 데이터 생성
      _user = UserModel(username: username, token: token);
      _isLoggedIn = true;
    } catch (e) {
      _isLoggedIn = false;
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    String? token = await _secureStorageService.readSecureData('token');
    if (token != null) {
      // 저장된 토큰이 있는 경우 로그인 상태 유지
      _user = UserModel(username: 'storedUser', token: token);
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }

    // 빌드가 완료된 후에 notifyListeners를 호출하도록 변경
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> logout() async {
    await _secureStorageService.deleteSecureData('token');
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
