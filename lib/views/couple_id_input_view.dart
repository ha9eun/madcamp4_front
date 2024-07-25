import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_models/login_view_model.dart';

class CoupleIdInputView extends StatefulWidget {
  @override
  _CoupleIdInputViewState createState() => _CoupleIdInputViewState();
}

class _CoupleIdInputViewState extends State<CoupleIdInputView> {
  final TextEditingController _partnerUsernameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  DateTime? _selectedStartDate;
  final themeColor = Color(0xFFCD001F);

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: themeColor,
            hintColor: themeColor,
            colorScheme: ColorScheme.light(primary: themeColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        _startDateController.text = DateFormat('yyyy년 MM월 dd일').format(_selectedStartDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/couple_info.png'), // 배경 이미지 설정
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
                      '커플 정보 입력',
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
                        controller: _partnerUsernameController,
                        decoration: InputDecoration(
                          labelText: '상대방 아이디',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectStartDate(context),
                      child: AbsorbPointer(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextField(
                            controller: _startDateController,
                            decoration: InputDecoration(
                              labelText: '시작 날짜',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_selectedStartDate == null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('오류'),
                                  content: Text('시작 날짜를 선택해주세요.'),
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
                              return;
                            }
                            try {
                              await loginViewModel.createCouple(
                                _partnerUsernameController.text,
                                _selectedStartDate!,
                                context,
                              );
                              Navigator.pushReplacementNamed(context, '/main');
                            } catch (e) {
                              if (e.toString().contains('409')) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('오류'),
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
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('오류'),
                                    content: Text('커플 생성에 실패했습니다. 다시 시도해주세요.'),
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
                              }
                            }
                          },
                          child: Text('제출'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: themeColor,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            textStyle: TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text('취소'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            textStyle: TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
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
