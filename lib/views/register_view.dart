import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/register_view_model.dart';
import 'couple_id_input_view.dart';
import 'login_view.dart';

class RegisterView extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final registerViewModel = Provider.of<RegisterViewModel>(context, listen: false);
    final themeColor = Color(0xFFCD001F);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '회원가입',
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
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: '닉네임',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Consumer<RegisterViewModel>(
                  builder: (context, registerViewModel, child) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: registerViewModel.isLoading ? null : () async {
                          await registerViewModel.register(
                            context,
                            _usernameController.text,
                            _passwordController.text,
                            _nicknameController.text,
                          );
                          if (!registerViewModel.isLoading) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => CoupleIdInputView()),
                            );
                          }
                        },
                        child: registerViewModel.isLoading
                            ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : Text(
                          '회원가입',
                          style: TextStyle(color: themeColor),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginView()),
                    );
                  },
                  child: Text(
                    '로그인으로 돌아가기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
