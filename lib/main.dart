import 'package:couple/view_models/letter_view_model.dart';
import 'package:couple/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/secure_storage_service.dart';
import 'view_models/login_view_model.dart';
import 'view_models/register_view_model.dart';
import 'view_models/user_view_model.dart';
import 'view_models/couple_view_model.dart';
import 'view_models/mission_view_model.dart';
import 'views/calendar_view.dart';
import 'views/login_view.dart';
import 'views/couple_id_input_view.dart';
import 'views/chat_view.dart';
import 'views/mission_view.dart';
import 'views/letter_view.dart';
import 'views/register_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final themeColor = Color(0xFFCD001F);

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
        ChangeNotifierProxyProvider2<UserViewModel, CoupleViewModel, MissionViewModel>(
          create: (context) => MissionViewModel(
            apiService: apiService,
            userViewModel: Provider.of<UserViewModel>(context, listen: false),
            coupleViewModel: Provider.of<CoupleViewModel>(context, listen: false),
          ),
          update: (context, userViewModel, coupleViewModel, missionViewModel) {
            return MissionViewModel(
              apiService: apiService,
              userViewModel: userViewModel,
              coupleViewModel: coupleViewModel,
            );
          },
        ),
        ChangeNotifierProxyProvider2<UserViewModel, CoupleViewModel, LetterViewModel>(
          create: (context) => LetterViewModel(
            apiService: apiService,
            userViewModel: Provider.of<UserViewModel>(context, listen: false),
            coupleViewModel: Provider.of<CoupleViewModel>(context, listen: false),
          ),
          update: (context, userViewModel, coupleViewModel, letterViewModel) {
            return LetterViewModel(
              apiService: apiService,
              userViewModel: userViewModel,
              coupleViewModel: coupleViewModel,
            );
          },
        ),
      ],
      child: MaterialApp(
        title: 'LoveLog',
        theme: ThemeData(
          primaryColor: themeColor,
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            hintStyle: TextStyle(color: Colors.black),
            labelStyle: TextStyle(color: Colors.black),
          ),
        ),
        home: SplashScreen(),
        routes: {
          '/auth_check': (context) => AuthCheck(),
          '/main': (context) => MainApp(),
          '/login': (context) => LoginView(),
          '/coupleInput': (context) => CoupleIdInputView(),
          '/register': (context) => RegisterView(),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    await loginViewModel.checkLoginStatus(context);

    if (loginViewModel.isLoggedIn) {
      if (userViewModel.user?.coupleId != null) {
        final coupleViewModel = Provider.of<CoupleViewModel>(context, listen: false);
        await coupleViewModel.fetchCoupleInfo();
        await coupleViewModel.fetchAnniversaries();
        await coupleViewModel.fetchSchedules();
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
      backgroundColor: Colors.grey[200],
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Color(0xFFCD001F),
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: '미션',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: '편지',
          ),
        ],
      ),
    );
  }
}
