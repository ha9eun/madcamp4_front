import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/login_view_model.dart';
import '../view_models/user_view_model.dart';
import 'calendar_view.dart';

class CoupleIdInputView extends StatelessWidget {
  final TextEditingController _partnerUsernameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Couple Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _partnerUsernameController,
              decoration: InputDecoration(labelText: 'Partner Username'),
            ),
            TextField(
              controller: _startDateController,
              decoration: InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await loginViewModel.createCouple(
                    _partnerUsernameController.text,
                    _startDateController.text,
                    context,
                  );
                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarView()),
                    );
                  });
                } catch (e) {
                  if (e.toString().contains('409')) {
                    // 409 상태 코드인 경우 경고 메시지 표시
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text('해당 사용자는 이미 다른 사람과 연결되어 있습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('확인'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // 다른 오류인 경우 일반 오류 메시지 표시
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text('Failed to create couple. Please try again.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
