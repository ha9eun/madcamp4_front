import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserViewModel extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  void debugPrintUserInfo() {
    print('User ID: ${_user?.id}');
    print('Username: ${_user?.username}');
    print('Nickname: ${_user?.nickname}');
    print('Couple ID: ${_user?.coupleId}');
  }
}
