import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../view_models/user_view_model.dart';
import '../view_models/couple_view_model.dart';
import 'chat_modal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  String? _selectedTopic;

  Future<void> _sendMessage(String message) async {
    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final coupleId = userViewModel.user?.coupleId;
      final senderId = userViewModel.user?.id;
      final senderNickname = userViewModel.user?.nickname ?? 'User';

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
          'topic': _selectedTopic ?? '',
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
          final aiMessage = messages.lastWhere((msg) => msg['senderId'] == null);
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

      final myNickname = userViewModel.user?.nickname ?? 'User1';
      final myId = userViewModel.user?.id;
      final partnerNickname = coupleViewModel.couple?.partnerNickname ?? 'User2';

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
                final message = _messages[index];
                final isMe = message['sender'] == myNickname;
                return GestureDetector(
                  onLongPress: message['sender'] == 'Bot'
                      ? () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Builder(
                          builder: (BuildContext newcontext) {
                            return ChatModal.showMissionModal(newcontext, message['message']);
                          }
                        );
                      },
                    );
                  }
                      : null,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isMe)
                          CircleAvatar(
                            child: Text(message['sender'][0]),
                          ),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.all(10.0),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['sender'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                message['message'],
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isMe)
                          SizedBox(width: 10),
                        if (isMe)
                          CircleAvatar(
                            child: Text(message['sender'][0]),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Buttons for topic selection
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTopicButton('대화주제', 'conversation'),
                SizedBox(width: 1),
                _buildTopicButton('데이트코스', 'date'),
                SizedBox(width: 1),
                _buildTopicButton('활동', 'activity'),
                SizedBox(width: 1),
                _buildTopicButton('싸움', 'fight'),
              ],
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
  Widget _buildTopicButton(String label, String topic) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTopic = topic;
        });
      },
      child: Text(label),
    );
  }

}
