import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/user_view_model.dart';
import '../view_models/couple_view_model.dart';
import '../view_models/mission_view_model.dart';

class ChatModal {
  static void showMissionModal(BuildContext context, String mission) {
    final TextEditingController _missionController = TextEditingController(text: mission);
    DateTime _selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('미션 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _missionController,
                decoration: InputDecoration(
                  labelText: '미션 제목',
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('날짜: ${_selectedDate.toLocal()}'.split(' ')[0]),
                  Spacer(),
                  TextButton(
                    child: Text('날짜 선택'),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != _selectedDate) {
                        _selectedDate = picked;
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('미션 수락!'),
              onPressed: () async {
                final coupleId = Provider.of<UserViewModel>(context, listen: false).user?.coupleId;

                if (coupleId != null) {
                  try {
                    await Provider.of<MissionViewModel>(context, listen: false)
                        .addMission(_missionController.text, _selectedDate);
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  } catch (e) {
                    print('Failed to create mission: $e');
                  }
                }
              },
            ),
            ElevatedButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
}
