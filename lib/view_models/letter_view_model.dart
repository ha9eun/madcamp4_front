import 'package:flutter/material.dart';
import '../models/letter_model.dart';
import '../services/api_service.dart';
import 'user_view_model.dart';
import 'couple_view_model.dart';

class LetterViewModel extends ChangeNotifier {
  final ApiService apiService;
  final UserViewModel userViewModel;
  final CoupleViewModel coupleViewModel;

  bool isLoading = false;
  List<Letter>? receivedLetters = [];
  List<Letter>? sentLetters = [];

  LetterViewModel({
    required this.apiService,
    required this.userViewModel,
    required this.coupleViewModel,
  });

  Future<void> fetchLetters() async {
    isLoading = true;
    notifyListeners();

    try {
      final coupleId = userViewModel.user?.coupleId;
      if (coupleId != null) {
        final response = await apiService.getLetters(coupleId);

        List<Letter> allLetters = response.map<Letter>((json) => Letter.fromJson(json)).toList();
        receivedLetters = allLetters.where((letter) => letter.senderId != userViewModel.user!.id).toList();
        sentLetters = allLetters.where((letter) => letter.senderId == userViewModel.user!.id).toList();
      }
    } catch (e) {
      print('Failed to fetch letters: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String getSenderName(String senderId) {
    if (senderId == userViewModel.user?.id) {
      return userViewModel.user?.nickname ?? 'You';
    } else {
      return coupleViewModel.couple?.partnerNickname ?? 'Partner';
    }
  }

  void clear() {
    receivedLetters = null;
    sentLetters = null;
    isLoading = false;
    notifyListeners();
  }
}
