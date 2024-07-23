import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../view_models/user_view_model.dart';
import '../view_models/couple_view_model.dart';

class ChatModal {
  static void showMissionModal(BuildContext context, String mission) {
    final TextEditingController _missionController = TextEditingController(text: mission);
    DateTime _selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Builder(
          builder: (BuildContext newContext) {
            final apiService = Provider.of<ApiService>(newContext, listen: false);
            final userViewModel = Provider.of<UserViewModel>(newContext, listen: false);
            final coupleViewModel = Provider.of<CoupleViewModel>(newContext, listen: false);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
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
                          final DateTime picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2101),
                          ) ?? _selectedDate;
                          if (picked != null && picked != _selectedDate) {
                            _selectedDate = picked;
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        child: Text('미션 수락!'),
                        onPressed: () async {
                          final coupleId = userViewModel.user?.coupleId;

                          if (coupleId != null) {
                            try {
                              await apiService.createMission(coupleId, _missionController.text, _selectedDate);
                              Navigator.pop(context);
                            } catch (e) {
                              print('Failed to create mission: $e');
                              // Handle error appropriately, e.g., show a message to the user
                            }
                          }
                        },
                      ),
                      ElevatedButton(
                        child: Text('닫기'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
