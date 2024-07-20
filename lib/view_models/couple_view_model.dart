import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/couple_model.dart';
import '../view_models/user_view_model.dart';

class CoupleViewModel extends ChangeNotifier {
  final ApiService apiService;
  final UserViewModel userViewModel;

  Couple? _couple;
  bool _isLoading = false;

  Couple? get couple => _couple;
  bool get isLoading => _isLoading;

  CoupleViewModel({
    required this.apiService,
    required this.userViewModel,
  });

  Future<void> fetchCoupleInfo() async {
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

      final response = await apiService.getCoupleInfo(coupleId);
      String myNickname = userViewModel.user?.nickname ?? '';
      _couple = Couple.fromJson(response, myNickname);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Failed to fetch couple info: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _couple = null;
    _isLoading = false;
    notifyListeners();
  }
}
