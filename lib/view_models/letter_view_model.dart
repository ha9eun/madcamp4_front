import 'package:flutter/material.dart';
import '../models/letter_model.dart';
import '../services/api_service.dart';
import 'user_view_model.dart';
import 'couple_view_model.dart';

class LetterViewModel extends ChangeNotifier {
  final ApiService apiService;
  final UserViewModel userViewModel;
  final CoupleViewModel coupleViewModel;

  List<Letter>? _letters = [];
  bool _isLoading = false;

  List<Letter>? get letters => _letters;
  bool get isLoading => _isLoading;

  LetterViewModel({
    required this.apiService,
    required this.userViewModel,
    required this.coupleViewModel,
  });

  Future<void> fetchLetters() async {
    _isLoading = true;
    notifyListeners();

    try {
      String? coupleId = userViewModel.user?.coupleId;
      if (coupleId == null) {
        throw Exception('coupleId is null');
      }
      final response = await apiService.getLetters(coupleId);
      _letters = (response as List).map((item) => Letter.fromJson(item)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Failed to fetch letters: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  String getSenderName(String senderId) {
    return senderId == userViewModel.user?.id
        ? '나'
        : coupleViewModel.couple?.partnerNickname ?? '상대방';
  }

  void clear() {
    _letters = null;
    _isLoading = false;
    notifyListeners();

  }
}
