import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/login_view_model.dart';
import 'calendar_view.dart';

class CoupleIdInputView extends StatelessWidget {
  final TextEditingController _coupleIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Couple ID'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _coupleIdController,
              decoration: InputDecoration(labelText: 'Couple ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 커플 ID 업데이트
                await loginViewModel.updateCoupleId(_coupleIdController.text);
                // Navigate to calendar view
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
