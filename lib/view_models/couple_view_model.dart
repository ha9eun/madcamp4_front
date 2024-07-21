import 'package:flutter/material.dart';
import '../models/anniversary_model.dart';
import '../services/api_service.dart';
import '../models/couple_model.dart';
import 'user_view_model.dart';

class CoupleViewModel extends ChangeNotifier {
  final ApiService apiService;
  final UserViewModel userViewModel;

  Couple? _couple;
  bool _isLoading = false;
  bool _isCoupleInfoFetched = false;

  Couple? get couple => _couple;
  bool get isLoading => _isLoading;
  bool get isCoupleInfoFetched => _isCoupleInfoFetched;

  CoupleViewModel({
    required this.apiService,
    required this.userViewModel,
  });

  Future<void> fetchCoupleInfo() async {
    if (_isCoupleInfoFetched) return;  // 이미 호출되었으면 리턴

    _isLoading = true;
    notifyListeners();

    try {
      String? coupleId = userViewModel.user?.coupleId;
      if (coupleId == null) {
        print('coupleId is null');
        _isLoading = false;
        notifyListeners();
        return;
      }
      print('couple_view_model coupleId: $coupleId');
      final response = await apiService.getCoupleInfo(coupleId);
      String myNickname = userViewModel.user?.nickname ?? '';
      _couple = Couple.fromJson(response, myNickname);

      _isCoupleInfoFetched = true;  // 정보 로드 완료
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Failed to fetch couple info: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnniversaries() async {
    _isLoading = true;
    notifyListeners();

    try {
      String? coupleId = userViewModel.user?.coupleId;
      if (coupleId == null) {
        print('coupleId is null');
        _isLoading = false;
        notifyListeners();
        return;
      }
      print('Fetching anniversaries for coupleId: $coupleId');
      final response = await apiService.getAnniversaries(coupleId);
      List<Anniversary> anniversaries = (response['anniversaries'] as List)
          .map((item) => Anniversary.fromJson(item))
          .toList();

      if (_couple != null) {
        _couple = _couple!.copyWith(anniversaries: anniversaries);
      } else {
        throw Exception('_couple is null');
      }

      _isLoading = false;
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('Failed to fetch anniversaries: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _couple = null;
    _isLoading = false;
    _isCoupleInfoFetched = false;  // 정보 초기화
    notifyListeners();
  }
}