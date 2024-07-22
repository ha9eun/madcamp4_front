import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';
import '../models/user_model.dart';
import 'user_view_model.dart';

class RegisterViewModel extends ChangeNotifier {
  final ApiService apiService;
  final SecureStorageService secureStorageService;

  bool _isLoading = false;
  User? _user;

  bool get isLoading => _isLoading;
  User? get user => _user;

  RegisterViewModel({
    required this.apiService,
    required this.secureStorageService,
  });

  Future<void> register(BuildContext context, String username, String password, String nickname) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiService.register(username, password, nickname);
      String userId = response['_id'] ?? '';

      // 사용자 정보 생성 및 Secure Storage에 저장
      _user = User.fromJson(response);
      await secureStorageService.writeSecureData('user_id', userId);

      // UserViewModel에 User 객체 설정
      Provider.of<UserViewModel>(context, listen: false).setUser(_user!);

      _isLoading = false;
      notifyListeners();

      print('회원가입 성공: ${userId}');
    } catch (e) {
      print('회원가입 실패: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
