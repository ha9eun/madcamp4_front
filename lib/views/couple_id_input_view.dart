import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/login_view_model.dart';
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
                // 커플 생성409
                await loginViewModel.createCouple(
                  _partnerUsernameController.text,
                  _startDateController.text,
                );
                // 캘린더 화면으로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarView()),
                );
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
