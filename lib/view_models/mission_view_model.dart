import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'user_view_model.dart';
import 'couple_view_model.dart';
import 'dart:io';
import '../models/mission_model.dart';

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

  Future<void> addMission(String mission, DateTime date) async {
    isLoading = true;
    notifyListeners();

    try {
      final coupleId = userViewModel.user?.coupleId;
      if (coupleId != null) {
        await apiService.createMission(coupleId, mission, date);
        await fetchMissions(); // Refresh the mission list after adding a new mission
      }
    } catch (e) {
      print('Failed to add mission: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMission(String id, String mission, DateTime date) async {
    isLoading = true;
    notifyListeners();

    try {
      await apiService.updateMission(id, mission, date);
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



  Future<void> completeMission({
    required String missionId,
    required String diary,
    required List<File> photos,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      Mission? mission = missions?.firstWhere((m) => m.id == missionId);
      if (mission != null) {
        await apiService.updateMissionDiary(
          missionId: missionId,
          coupleId: mission.coupleId,
          date: mission.date,
          mission: mission.mission,
          diary: diary,
        );
        final response = await apiService.uploadMissionPhotos(missionId, photos);


        final updatedMission = Mission(
          id: missionId,
          coupleId: mission.coupleId,
          mission: mission.mission,
          date: mission.date.toLocal(),
          photos: List<String>.from(response['photos']),
          diary: diary,
        );
        final index = missions!.indexWhere((mission) => mission.id == missionId);
        if (index != -1) {
          missions![index] = updatedMission;
        }
      }
    } catch (e) {
      print('Failed to complete mission: $e');
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
