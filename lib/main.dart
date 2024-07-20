import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/secure_storage_service.dart';
import 'view_models/login_view_model.dart';
import 'views/calendar_view.dart';
import 'views/login_view.dart';
import 'views/couple_id_input_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final secureStorageService = SecureStorageService();
    final apiService = ApiService(secureStorageService: secureStorageService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(
            apiService: apiService,
            secureStorageService: secureStorageService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Couple',
        home: AuthCheck(),
      ),
    );
  }
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    await loginViewModel.checkLoginStatus();
    if (loginViewModel.isLoggedIn) {
      if (loginViewModel.user?.coupleId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CalendarView()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CoupleIdInputView()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
