// lib/services/api_service.dart


import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:couple/config.dart';
import 'package:intl/intl.dart';
import '../models/letter_model.dart';
import 'secure_storage_service.dart';
import 'dart:io';

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
  Future<Map<String, dynamic>> createCouple(String userId, String partnerUsername, DateTime startDate) async {
    print('createCouple startDate: $startDate');
    print('request body: ${startDate.toUtc().toIso8601String()}');
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/users/couple/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'partnerUsername': partnerUsername,
        'startDate': startDate.toUtc().toIso8601String(),
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

  Future<List<dynamic>> getSchedules(String coupleId) async {
    print('getSchedules API 호출');
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/calendar/couples/$coupleId/schedules'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print('getSchedules 응답 상태 코드: ${response.statusCode}');
    print('getSchedules 응답 바디: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch schedules');
    }
  }

  Future<Map<String, dynamic>> addSchedule(String coupleId, DateTime date, String title) async {
    print('addSchedule API 호출');
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/calendar/schedule'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'coupleId': coupleId,
        'date':date.toIso8601String(),
        'title': title,
      }),
    );
    print('addSchedule API statusCode: ${response.statusCode}');
    print('addSchedule API response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Failed to add schedule');
    }

    return json.decode(response.body);
  }

  Future<void> updateSchedule(String scheduleId, DateTime date, String title) async {
    print('updateschedule API 호출');
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/calendar/schedule/$scheduleId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'date': date.toIso8601String(),
        'title': title,
      }),
    );
    print('updateschedule statusCode: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update schedule');
    }
  }


  Future<List<dynamic>> getLetters(String coupleId) async {
    print('getLetters API 호출');
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/letters/couple/$coupleId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print('getLetters statusCode: ${response.statusCode}');
    print('getLetters response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get letters');
    }
  }
  
  Future<void> deleteSchedule(String id) async {
    final response = await http.delete(
      Uri.parse('${Config.baseUrl}/calendar/schedule/$id')
    );

    if(response.statusCode != 200) {
      throw Exception('Failed to delete schedule');

    }
  }


  // Mission APIs

  Future<Map<String, dynamic>> createMission(String coupleId, String mission, DateTime date) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/missions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'coupleId': coupleId,
        'mission': mission,
        'date': date.toIso8601String(),
      }),
    );
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create mission!!');
    }
  }

  Future<List<dynamic>> getMissions(String coupleId) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/missions/$coupleId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch missions');
    }
  }

  Future<Map<String, dynamic>> getMissionById(String id) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/missions/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch mission');
    }
  }

  Future<void> updateMission(String id, String title, DateTime date) async {
    final response = await http.patch(
      Uri.parse('${Config.baseUrl}/missions/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'date': date.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update mission');
    }
  }

  Future<void> deleteMission(String id) async {
    final response = await http.delete(
      Uri.parse('${Config.baseUrl}/missions/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete mission');
    }
  }

  Future<Map<String, dynamic>> addLetter({
    required String title,
    required String content,
    required DateTime date,
    required List<File>? photos,
    required String coupleId,
    required String senderId,
  }) async {
    final uri = Uri.parse('${Config.baseUrl}/letters');
    print('coupleId: $coupleId');
    print('senderId: $senderId');
    print('title: $title');
    print('date: $date');
    print('photos $photos');

    var request = http.MultipartRequest('POST', uri)
      ..fields['coupleId'] = coupleId
      ..fields['title'] = title
      ..fields['content'] = content
      ..fields['date'] = date.toIso8601String()
      ..fields['senderId'] = senderId;

    if (photos != null && photos.isNotEmpty) {
      for (var file in photos) {
        request.files.add(await http.MultipartFile.fromPath('photos', file.path));
      }
    }

    var response = await request.send();
    print('response.statusCode: ${response.statusCode}');
    print('response.body: ${response.stream}');
    if (response.statusCode == 201) {
      var responseData = await http.Response.fromStream(response);
      return jsonDecode(responseData.body);

    } else {
      throw Exception('Failed to upload letter');
    }
  }

  // 편지 텍스트 수정 API 호출
  Future<void> updateLetter({
    required String id,
    required String title,
    required String content,
    required DateTime date,
  }) async {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/letters/$id/content'),
      headers:  <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'date': date.toIso8601String(),
      }),
    );
    print('편지 텍스트 수정 API 상태 코드: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Failed to update letter');
    }
  }

  // 사진 삭제 API 호출
  Future<void> deletePhoto(String id, String url) async {
    final response = await http.delete(
      Uri.parse('${Config.baseUrl}/letters/$id/images?img-url=$url'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print('사진 삭제 API 상태 코드: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete photo');
    }
  }

  // 사진 추가 API 호출
  Future<Map<String, dynamic>> uploadPhoto(String id, List<File> photos) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${Config.baseUrl}/letters/$id/images'),
    );


    for (var file in photos) {
      request.files.add(
          await http.MultipartFile.fromPath('photos', file.path));
    }


    final response = await request.send();
    print('사진 추가 API 상태 코드: ${response.statusCode}');
    if (response.statusCode == 201) {
      var responseData = await http.Response.fromStream(response);
      return jsonDecode(responseData.body);
    } else {
      throw Exception('Failed to upload photo');
    }
  }

  Future<void> updateMissionDiary({
    required String missionId,
    required String coupleId,
    required DateTime date,
    required String mission,
    required String diary,
  }) async {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/missions/$missionId/content'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'coupleId': coupleId,
        'date': date.toIso8601String(),
        'mission': mission,
        'diary': diary,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update mission diary');
    }
  }

  Future<Map<String, dynamic>> uploadMissionPhotos(String missionId, List<File> photos) async {
    final uri = Uri.parse('${Config.baseUrl}/missions/$missionId/images');

    var request = http.MultipartRequest('POST', uri);

    for (var file in photos) {
      request.files.add(await http.MultipartFile.fromPath('photos', file.path));
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      var responseData = await http.Response.fromStream(response);
      return jsonDecode(responseData.body);
    } else {
      throw Exception('Failed to upload mission photos');
    }
  }

}
