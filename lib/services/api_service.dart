// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:couple/config.dart';
import 'secure_storage_service.dart';

class ApiService {

  final SecureStorageService secureStorageService;
  ApiService({required this.secureStorageService});

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

    print('login 응답 상태 코드: ${response.statusCode}');
    print('login 응답 바디: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;

    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/users/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print('getUserInfo statusCode: ${response.statusCode}');
    print('getUserInfo response.body : ${response.body}');
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to fetch user info');
    }
  }

  Future<void> updateCoupleId(String userId, String coupleId) async {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/users/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'coupleId': coupleId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update couple ID');
    }
  }
}
