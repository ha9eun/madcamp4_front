import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/secure_storage_service.dart';
import 'view_models/login_view_model.dart';
import 'view_models/register_view_model.dart';
import 'view_models/user_view_model.dart';
import 'view_models/couple_view_model.dart';
import 'views/calendar_view.dart';
import 'views/login_view.dart';
import 'views/couple_id_input_view.dart';
import 'views/chat_view.dart';
import 'views/mission_view.dart';
import 'views/letter_view.dart';

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
          create: (_) => RegisterViewModel(
            apiService: apiService,
            secureStorageService: secureStorageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(
            apiService: apiService,
            secureStorageService: secureStorageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => UserViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => CoupleViewModel(
            apiService: apiService,
            userViewModel: Provider.of<UserViewModel>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Couple',
        initialRoute: '/',
        routes: {
          '/': (context) => AuthCheck(),
          '/main': (context) => MainApp(),
          '/login': (context) => LoginView(),
          '/coupleInput': (context) => CoupleIdInputView(),
        },
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
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    await loginViewModel.checkLoginStatus(context);

    if (loginViewModel.isLoggedIn) {
      if (userViewModel.user?.coupleId != null) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/coupleInput');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    CalendarView(),
    ChatView(),
    MissionView(),
    LetterView()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Scaffold의 기본 배경 색상 설정
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        backgroundColor: Colors.blue, // BottomNavigationBar의 배경 색상 설정
        selectedItemColor: Colors.yellow, // 선택된 아이템의 색상 설정
        unselectedItemColor: Colors.black, // 선택되지 않은 아이템의 색상 설정
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Mission',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Letter',
          ),
        ],
      ),
    );
  }
}
