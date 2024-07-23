import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/letter_model.dart';
import '../services/api_service.dart';
import 'user_view_model.dart';
import 'couple_view_model.dart';
import 'dart:io';

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

  Future<void> addLetter({
    required String title,
    required String content,
    required DateTime date,
    List<File>? photos,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final coupleId = userViewModel.user?.coupleId;
      final senderId = userViewModel.user?.id;

      if (coupleId != null && senderId != null) {
        final response = await apiService.addLetter(
          coupleId: coupleId,
          senderId: senderId,
          title: title,
          content: content,
          date: date.toUtc(),
          photos: photos,
        );

        final newLetter = Letter(
          id: response['_id'],
          title: title,
          content: content,
          photoUrls: photos != null ? List<String>.from(response['photos']) : null,
          date: date,
          senderId: senderId,
        );

        sentLetters?.add(newLetter);
      }
    } catch (e) {
      print('Failed to send letter: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    receivedLetters = null;
    sentLetters = null;
    isLoading = false;
    notifyListeners();
  }
}
