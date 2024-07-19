import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/login_view_model.dart';

class CalendarView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              loginViewModel.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, ${loginViewModel.user?.username}!'),
      ),
    );
  }
}
