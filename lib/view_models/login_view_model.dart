import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/secure_storage_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../view_models/user_view_model.dart';
import 'couple_view_model.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService apiService;
  final SecureStorageService secureStorageService;

  bool _isLoading = false;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  LoginViewModel({
    required this.apiService,
    required this.secureStorageService,
  });

  Future<void> login(String username, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiService.login(username, password);
      String userId = response['_id'];

      // Secure Storage에 사용자 ID 저장
      await secureStorageService.writeSecureData('user_id', userId);

      // UserViewModel에 User 객체 설정
      User user = User.fromJson(response);
      Provider.of<UserViewModel>(context, listen: false).setUser(user);

      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();

      print('로그인 성공: ${userId}');

      // 로그인 후 커플 정보 로드
      if (user.coupleId != null) {
        await Provider.of<CoupleViewModel>(context, listen: false).fetchCoupleInfo();
        await Provider.of<CoupleViewModel>(context, listen: false).fetchAnniversaries();
        await Provider.of<CoupleViewModel>(context, listen: false).fetchSchedules();
      }

    } catch (e) {
      print('로그인 실패: $e');
      _isLoggedIn = false;
      _isLoading = false;
      notifyListeners();
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
        User user = User.fromJson(response);

        // UserViewModel에 User 객체 설정
        Provider.of<UserViewModel>(context, listen: false).setUser(user);
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

  Future<void> createCouple(String partnerUsername, DateTime startDate, BuildContext context) async {
    User? user = Provider.of<UserViewModel>(context, listen: false).user;
    if (user != null) {
      try {
        DateTime utcDate = DateTime(startDate.year, startDate.month, startDate.day, 24, 0);
        final response = await apiService.createCouple(user.id, partnerUsername, utcDate);

        String coupleId = response['_id'];

        // 기존 User 객체 업데이트
        user = user.copyWith(coupleId: coupleId);
        print("user coupleId: ${user.coupleId}");
        // UserViewModel에 업데이트된 User 객체 설정
        Provider.of<UserViewModel>(context, listen: false).setUser(user);

        notifyListeners();
        Provider.of<UserViewModel>(context, listen: false).debugPrintUserInfo(); // 디버깅 정보 출력


        final coupleViewModel = Provider.of<CoupleViewModel>(context, listen: false);
        await coupleViewModel.fetchCoupleInfo();
        await coupleViewModel.fetchAnniversaries();
        await coupleViewModel.fetchSchedules();


      } catch (e) {
        if (e.toString().contains('409')) {
          throw Exception('409');
        } else {
          print('커플 생성 실패: $e');
          throw Exception('Failed to create couple');
        }
      }
    } else {
      print('createCouple: user가 null입니다');
    }
  }

  Future<void> logout(BuildContext context) async {
    await secureStorageService.deleteSecureData('user_id');
    Provider.of<UserViewModel>(context, listen: false).clearUser();
    Provider.of<CoupleViewModel>(context, listen: false).clear();
    _isLoggedIn = false;
    notifyListeners();
  }
}
