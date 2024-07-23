import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'user_view_model.dart';
import 'couple_view_model.dart';
import 'dart:io';

class Mission {
  final String id;
  final String coupleId;
  final String mission;
  final DateTime date;
  final List<String>? photos;
  final String? aiComment;
  final String? diary;

  Mission({
    required this.id,
    required this.coupleId,
    required this.mission,
    required this.date,
    this.photos,
    this.aiComment,
    this.diary,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['_id'],
      coupleId: json['coupleId'],
      mission: json['mission'],
      date: DateTime.parse(json['date']),
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      aiComment: json['aiComment'],
      diary: json['diary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'coupleId': coupleId,
      'mission': mission,
      'date': date,
      'photos': photos,
      'aiComment': aiComment,
      'diary': diary,
    };
  }
}

class MissionViewModel extends ChangeNotifier {
  final ApiService apiService;
  final UserViewModel userViewModel;
  final CoupleViewModel coupleViewModel;

  bool isLoading = false;
  List<Mission>? missions = [];

  MissionViewModel({
    required this.apiService,
    required this.userViewModel,
    required this.coupleViewModel,
  });

  Future<void> fetchMissions() async {
    isLoading = true;
    notifyListeners();

    try {
      final coupleId = userViewModel.user?.coupleId;
      if (coupleId != null) {
        final response = await apiService.getMissions(coupleId);
        missions = response.map<Mission>((json) => Mission.fromJson(json)).toList();
      }
    } catch (e) {
      print('Failed to fetch missions: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMission(String title, DateTime date) async {
    isLoading = true;
    notifyListeners();

    try {
      final coupleId = userViewModel.user?.coupleId;
      if (coupleId != null) {
        await apiService.createMission(coupleId, title, date);
        await fetchMissions(); // Refresh the mission list after adding a new mission
      }
    } catch (e) {
      print('Failed to add mission: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMission(String id, String title, DateTime date) async {
    isLoading = true;
    notifyListeners();

    try {
      await apiService.updateMission(id, title, date);
      await fetchMissions(); // Refresh the mission list after updating a mission
    } catch (e) {
      print('Failed to update mission~~: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMission(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      await apiService.deleteMission(id);
      await fetchMissions(); // Refresh the mission list after deleting a mission
    } catch (e) {
      print('Failed to delete mission: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    missions = null;
    isLoading = false;
    notifyListeners();
  }
}
