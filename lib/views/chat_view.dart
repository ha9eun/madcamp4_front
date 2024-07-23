// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:provider/provider.dart';
// import '../config/config.dart';
// import '../view_models/user_view_model.dart';
//
// class ChatView extends StatefulWidget {
//   @override
//   _ChatViewState createState() => _ChatViewState();
// }
//
// class _ChatViewState extends State<ChatView> {
//   final TextEditingController _controller = TextEditingController();
//   List<Map<String, dynamic>> _messages = [];
//
//   Future<void> _sendMessage(String message) async {
//     try {
//       final userViewModel = Provider.of<UserViewModel>(context, listen: false);
//       final coupleId = userViewModel.user?.coupleId;
//       final senderId = userViewModel.user?.id;
//       final senderNickname = userViewModel.user?.nickname ?? 'User';
//
//       if (coupleId == null || senderId == null) {
//         throw Exception('Invalid coupleId or senderId');
//       }
//
//       final response = await http.post(
//         Uri.parse('${Config.baseUrl}/chat'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, String>{
//           'coupleId': coupleId,
//           'senderId': senderId,
//           'senderType': 'user',
//           'message': message,
//         }),
//       );
//
//       if (response.statusCode == 201) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         final List<dynamic> messages = data['messages'];
//         setState(() {
//           _messages.add({
//             'sender': senderNickname,
//             'message': message,
//           });
//           final aiMessage = messages.lastWhere((msg) => msg['senderType'] == 'ai' && msg['senderId'] == null);
//           _messages.add({
//             'sender': 'Bot',
//             'message': aiMessage['message'],
//           });
//         });
//       } else {
//         throw Exception('Failed to send message');
//       }
//     } catch (e) {
//       print(e);
//       throw Exception('Failed to send message');
//     }
//   }
//
//   Future<void> _fetchChatHistory() async {
//     try {
//       final userViewModel = Provider.of<UserViewModel>(context, listen: false);
//       final coupleId = userViewModel.user?.coupleId;
//
//       if (coupleId == null) {
//         throw Exception('Invalid coupleId');
//       }
//
//       final response = await http.get(
//         Uri.parse('${Config.baseUrl}/chat/$coupleId'),
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body)['messages'];
//         setState(() {
//           _messages = data.map((message) {
//             return {
//               'sender': message['senderType'] == 'user' ? userViewModel.user?.nickname ?? 'User' : 'Bot',
//               'message': message['message'],
//             };
//           }).toList();
//         });
//       } else {
//         throw Exception('Failed to load chat history');
//       }
//     } catch (e) {
//       print(e);
//       throw Exception('Failed to load chat history');
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchChatHistory();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text('${_messages[index]['sender']}: ${_messages[index]['message']}'),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'Enter your message',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () {
//                     _sendMessage(_controller.text);
//                     _controller.clear();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:provider/provider.dart';
// import '../config/config.dart';
// import '../view_models/user_view_model.dart';
// import '../view_models/couple_view_model.dart';
//
// class ChatView extends StatefulWidget {
//   @override
//   _ChatViewState createState() => _ChatViewState();
// }
//
// class _ChatViewState extends State<ChatView> {
//   final TextEditingController _controller = TextEditingController();
//   List<Map<String, dynamic>> _messages = [];
//
//   Future<void> _sendMessage(String message) async {
//     try {
//       final userViewModel = Provider.of<UserViewModel>(context, listen: false);
//       final coupleId = userViewModel.user?.coupleId;
//       final senderId = userViewModel.user?.id;
//       final senderNickname = userViewModel.user?.nickname ?? 'User';
//
//       if (coupleId == null || senderId == null) {
//         throw Exception('Invalid coupleId or senderId');
//       }
//
//       final response = await http.post(
//         Uri.parse('${Config.baseUrl}/chat'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, String>{
//           'coupleId': coupleId,
//           'senderId': senderId,
//           'senderType': 'user',
//           'message': message,
//         }),
//       );
//
//       if (response.statusCode == 201) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         final List<dynamic> messages = data['messages'];
//         setState(() {
//           _messages.add({
//             'sender': senderNickname,
//             'message': message,
//           });
//           final aiMessage = messages.lastWhere((msg) => msg['senderType'] == 'ai' && msg['senderId'] == null);
//           _messages.add({
//             'sender': 'Bot',
//             'message': aiMessage['message'],
//           });
//         });
//       } else {
//         throw Exception('Failed to send message');
//       }
//     } catch (e) {
//       print(e);
//       throw Exception('Failed to send message');
//     }
//   }
//
//   Future<void> _fetchChatHistory() async {
//     try {
//       final userViewModel = Provider.of<UserViewModel>(context, listen: false);
//       final coupleId = userViewModel.user?.coupleId;
//
//       if (coupleId == null) {
//         throw Exception('Invalid coupleId');
//       }
//
//       final response = await http.get(
//         Uri.parse('${Config.baseUrl}/chat/$coupleId'),
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body)['messages'];
//         setState(() {
//           _messages = data.map((message) {
//             return {
//               'sender': message['senderType'] == 'user' ? userViewModel.user?.nickname ?? 'User' : 'Bot',
//               'message': message['message'],
//             };
//           }).toList();
//         });
//       } else {
//         throw Exception('Failed to load chat history');
//       }
//     } catch (e) {
//       print(e);
//       throw Exception('Failed to load chat history');
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchChatHistory();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userViewModel = Provider.of<UserViewModel>(context);
//     final coupleViewModel = Provider.of<CoupleViewModel>(context);
//     final user1Nickname = userViewModel.user?.nickname ?? 'User1';
//     final user2Nickname = coupleViewModel.couple?.partnerNickname ?? 'User2';
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$user1Nickname and $user2Nickname\'s Chat'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text('${_messages[index]['sender']}: ${_messages[index]['message']}'),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'Enter your message',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () {
//                     _sendMessage(_controller.text);
//                     _controller.clear();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../config/config.dart';
import '../view_models/user_view_model.dart';
import '../view_models/couple_view_model.dart';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  Future<void> _sendMessage(String message) async {
    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final coupleId = userViewModel.user?.coupleId;
      final senderId = userViewModel.user?.id;
      final senderNickname = userViewModel.user?.nickname ?? '보내는이의 닉네임 알수 없음';

      if (coupleId == null || senderId == null) {
        throw Exception('Invalid coupleId or senderId');
      }

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/chat'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'coupleId': coupleId,
          'senderId': senderId,
          'message': message,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> messages = data['messages'];
        setState(() {
          _messages.add({
            'sender': senderNickname,
            'message': message,
          });
          final aiMessage = messages.lastWhere((msg) => msg['senderId'] == null); // Assuming 'AI' is used for bot messages
          _messages.add({
            'sender': 'Bot',
            'message': aiMessage['message'],
          });
        });
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to send message');
    }
  }

  Future<void> _fetchChatHistory() async {
    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final coupleViewModel = Provider.of<CoupleViewModel>(context, listen: false);
      final coupleId = userViewModel.user?.coupleId;

      if (coupleId == null) {
        throw Exception('Invalid coupleId');
      }

      final myNickname = userViewModel.user?.nickname ?? '내 닉네임 알 수 없음';
      final myId = userViewModel.user?.id;
      final partnerNickname = coupleViewModel.couple?.partnerNickname ?? '파트너 닉네임 알 수 없음';

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/chat/$coupleId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['messages'];
        setState(() {
          _messages = data.map((message) {
            String sender;
            if (message['senderId'] == myId) {
              sender = myNickname;
            } else if (message['senderId'] == null) {
              sender = 'Bot';
            } else {
              sender = partnerNickname;
            }
            return {
              'sender': sender,
              'message': message['message'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load chat history');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load chat history');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final coupleViewModel = Provider.of<CoupleViewModel>(context);
    final myNickname = userViewModel.user?.nickname ?? 'User1';
    final partnerNickname = coupleViewModel.couple?.partnerNickname ?? 'User2';

    return Scaffold(
      appBar: AppBar(
        title: Text('$myNickname and $partnerNickname\'s Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${_messages[index]['sender']}: ${_messages[index]['message']}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}