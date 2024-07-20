
import 'package:couple/view_models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  Future<void> login(String username, String password, BuildContext context) async {
    try {
      final response = await apiService.login(username, password);
      String userId = response['_id'];

      // 사용자 정보 생성 및 Secure Storage에 저장
      _user = User.fromJson(response);
      // UserViewModel에 User 객체 설정
      Provider.of<UserViewModel>(context, listen: false).setUser(_user!);

      await secureStorageService.writeSecureData('user_id', userId);

      _isLoggedIn = true;
      notifyListeners();

      print('로그인 성공: ${userId}');
    } catch (e) {
      print('로그인 실패: $e');
    }
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    String? userId = await secureStorageService.readSecureData('user_id');
    if (userId != null) {
      // 저장된 사용자 ID가 있는 경우 사용자 정보 불러오기
      try {
        final response = await apiService.getUserInfo(userId);
        _user = User.fromJson(response);

        // UserViewModel에 User 객체 설정
        Provider.of<UserViewModel>(context, listen: false).setUser(_user!);
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

  Future<void> createCouple(String partnerUsername, String startDate) async {
    if (_user != null) {
      try {
        final response = await apiService.createCouple(_user!.id, partnerUsername, startDate);
        String coupleId = response['coupleId'] ?? '';


        _user = User(
          id: _user!.id,
          username: _user!.username,
          nickname: _user!.nickname,
          coupleId: coupleId,
        );
        notifyListeners();
      } catch (e) {
        if (e.toString().contains('409')) {
          throw Exception('409');
        } else {
          print('커플 생성 실패: $e');
          throw Exception('Failed to create couple');
        }

      }
    } else {
      print('createCouple: _user가 null입니다');
    }
  }

  Future<void> logout() async {
    await secureStorageService.deleteSecureData('user_id');
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
