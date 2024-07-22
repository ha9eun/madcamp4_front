// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:couple/config/config.dart';
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
      return json.decode(response.body);
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
  Future<Map<String, dynamic>> createCouple(String userId, String partnerUsername, String startDate) async {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/users/couple/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'partnerUsername': partnerUsername,
        'startDate': startDate,
      }),
    );
    print('createCouple API response body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 409) {
      throw Exception('409');
    } else {
      throw Exception('Failed to create couple');
    }
  }

  Future<Map<String, dynamic>> register(String username, String password, String nickname) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/users/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'nickname': nickname,
      }),
    );

    if (response.statusCode == 201) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<Map<String, dynamic>> getCoupleInfo(String coupleId) async {
    print('getCoupleInfo APi coupleId: $coupleId');
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/calendar/couples/$coupleId/coupleInfo'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print('getCoupleInfo API statusCode: ${response.statusCode}');
    print('getCoupleInfo API response.body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch couple info');
    }
  }

  Future<Map<String, dynamic>> getAnniversaries(String coupleId) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/calendar/couples/$coupleId/anniversaries'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch anniversaries');
    }
  }

}
