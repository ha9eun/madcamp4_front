import 'package:flutter/material.dart';
import '../models/anniversary_model.dart';
import '../models/schedule_model.dart';
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

  Future<void> fetchSchedules() async {
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
      print('Fetching schedules for coupleId: $coupleId');
      final response = await apiService.getSchedules(coupleId);
      List<Schedule> schedules = (response)
          .map((item) => Schedule.fromJson(item))
          .toList();

      if (_couple != null) {
        _couple = _couple!.copyWith(schedules: schedules);
      } else {
        throw Exception('_couple is null');
      }

      _isLoading = false;
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('Failed to fetch schedules: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSchedule(DateTime date, String title) async {
    try {
      String? coupleId = userViewModel.user?.coupleId;
      if (coupleId == null) {
        throw Exception('coupleId is null');
      }
      DateTime utcDate = DateTime(date.year, date.month, date.day,24,0);
      print("add schedule request body date: $utcDate");
      final response = await apiService.addSchedule(coupleId, utcDate, title);
      String scheduleId = response['_id'];
      DateTime scheduleDate = DateTime.parse(response['date']);
      print('add schedule response body date : $scheduleDate');
      String scheduleTitle = response['title'];

      Schedule newSchedule = Schedule(
        id: scheduleId,
        date: scheduleDate,
        title: scheduleTitle,
      );

      _couple?.schedules.add(newSchedule);
      print('couple_view_model: schedule이 성공적으로 추가되었습니다.');
      notifyListeners();
    } catch (e) {
      print('Failed to add schedule: $e');
      throw e;
    }
  }

  Future<void> updateSchedule(String scheduleId, DateTime date, String title) async {
    if (_isLoading) return;  // 이미 호출되었으면 리턴

    _isLoading = true;
    notifyListeners();
    DateTime utcDate = DateTime(date.year, date.month, date.day, 24,0);
    print('updateSchedule utcDate: $utcDate');
    try {
      await apiService.updateSchedule(scheduleId, utcDate, title);

      Schedule updatedSchedule = Schedule(
        id: scheduleId,
        date: date,
        title: title,
      );

      if (_couple != null) {
        List<Schedule> updatedSchedules = List.from(_couple!.schedules);
        int index = updatedSchedules.indexWhere((schedule) => schedule.id == scheduleId);
        if (index != -1) {
          updatedSchedules[index] = updatedSchedule;
          _couple = _couple!.copyWith(schedules: updatedSchedules);
          _isLoading = false;
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            notifyListeners();
          });
          print('update schedule notify 완료');
        }
      }
    } catch (e) {
      print('Failed to update schedule: $e');
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteSchedule(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await apiService.deleteSchedule(id);
      _couple?.schedules.removeWhere((schedule) => schedule.id == id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Failed to delete schedule: $e');
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
