import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/login_view_model.dart';
import '../view_models/user_view_model.dart';
import 'register_view.dart';

class LoginView extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    final themeColor = Color(0xFFCD001F);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: '아이디',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 8),
                    Consumer<LoginViewModel>(
                      builder: (context, loginViewModel, child) {
                        return Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: ElevatedButton(
                                onPressed: loginViewModel.isLoading ? null : () async {
                                  await loginViewModel.login(
                                    _usernameController.text,
                                    _passwordController.text,
                                    context,
                                  );
                                  if (loginViewModel.isLoggedIn) {
                                    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
                                    if (userViewModel.user?.coupleId != null) {
                                      Navigator.pushReplacementNamed(context, '/main');
                                    } else {
                                      Navigator.pushReplacementNamed(context, '/coupleInput');
                                    }
                                  }
                                },
                                child: loginViewModel.isLoading
                                    ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                                    : Text(
                                  '로그인',
                                  style: TextStyle(color: themeColor),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  textStyle: TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: themeColor),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 0),  // 줄여진 거리
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RegisterView()),
                                );
                              },
                              child: Text(
                                '회원가입',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
