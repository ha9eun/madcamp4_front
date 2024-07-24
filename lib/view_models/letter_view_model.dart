// lib/view_models/letter_view_model.dart

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
        sentLetters?.forEach((element) {
          print(element.title);
          print(element.photoUrls);
        });
        print('receivedLetters: $receivedLetters');
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

  Future<void> updateLetter({
    required String id,
    required String title,
    required String content,
    required DateTime date,
    List<File>? newPhotos,
    List<String>? existingPhotoUrls,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      // 무조건 텍스트 수정 API 호출
      await apiService.updateLetter(
        id: id,
        title: title,
        content: content,
        date: date.toUtc(),
      );

      // 기존 편지 객체 찾기
      final letter = sentLetters!.firstWhere((letter) => letter.id == id);
      print('기존 편지 id: ${letter.id}');
      // 디버깅을 위해 리스트 상태 출력
      print('디버깅 existingPhotoUrls: $existingPhotoUrls');
      print('디버깅 letter.photoUrls: ${letter.photoUrls}');

      // 사진 삭제 API 호출
      if (letter.photoUrls != null) { //기존 사진이 있으면
        print('편지 사진이 있음');
        for (var url in letter.photoUrls!) {
          if (existingPhotoUrls == null || !existingPhotoUrls.contains(url)) {
            print('삭제할 사진 url: $url');
            await apiService.deletePhoto(letter.id, url);
          }
        }
      }

      // 새로운 사진 추가 API 호출 및 새 사진 링크 받기
      List<String> newPhotoUrls = [];
      if (newPhotos != null && newPhotos.isNotEmpty) {
        final response = await apiService.uploadPhoto(id, newPhotos);
        newPhotoUrls = List<String>.from(response['photos']);
      }

      // 기존 사진 링크와 새로운 사진 링크 합치기
      final updatedPhotoUrls = [
        if (existingPhotoUrls != null) ...existingPhotoUrls,
        ...newPhotoUrls,
      ];

      // 로컬 상태 업데이트
      final updatedLetter = Letter(
        id: id,
        title: title,
        content: content,
        photoUrls: updatedPhotoUrls,
        date: date,
        senderId: userViewModel.user!.id,
      );

      // 로컬 상태에서 편지 업데이트
      final index = sentLetters!.indexWhere((letter) => letter.id == id);
      if (index != -1) {
        sentLetters![index] = updatedLetter;
      }

      notifyListeners();
    } catch (e) {
      print('Failed to update letter: $e');
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
