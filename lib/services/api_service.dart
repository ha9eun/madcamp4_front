// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String username, String password) async {
    print('login 함수 호출됨');
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/users/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    print('응답 상태 코드: ${response.statusCode}');
    print('응답 바디: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;

    } else {
      throw Exception('Failed to login');
    }
  }
}
