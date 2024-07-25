import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/letter_model.dart';
import '../view_models/letter_view_model.dart';
import 'write_letter_view.dart';
import 'letter_detail_view.dart';

class LetterView extends StatefulWidget {
  @override
  _LetterViewState createState() => _LetterViewState();
}

class _LetterViewState extends State<LetterView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LetterViewModel>(context, listen: false).fetchLetters();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final letterViewModel = Provider.of<LetterViewModel>(context);
    final themeColor = Color(0xFFCD001F);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: themeColor,
              labelColor: themeColor,
              unselectedLabelColor: Colors.black54,
              tabs: [
                Tab(text: '받은 편지함'),
                Tab(text: '보낸 편지함'),
              ],
            ),
            Expanded(
              child: letterViewModel.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : TabBarView(
                controller: _tabController,
                children: [
                  _buildLetterList(letterViewModel.receivedLetters, letterViewModel, isSent: false),
                  _buildLetterList(letterViewModel.sentLetters, letterViewModel, isSent: true),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WriteLetterView()),
          );
        },
        backgroundColor: themeColor,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildLetterList(List<Letter?>? letters, LetterViewModel letterViewModel, {required bool isSent}) {
    if (letters == null || letters.isEmpty) {
      return Center(child: Text('No letters found', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        if (letter == null) return SizedBox.shrink(); // Null safety check
        final senderName = letterViewModel.getSenderName(letter.senderId);
        final now = DateTime.now();
        final isSentComplete = letter.date.isBefore(now);

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16.0),
            title: Text(letter.title ?? 'No Title', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('From: $senderName', style: TextStyle(color: Colors.grey[600])),
                Text(
                  '${DateFormat('yyyy-MM-dd HH:mm').format(letter.date)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: isSent
                ? Text(
              isSentComplete ? '전송 완료' : '전송 전',
              style: TextStyle(color: isSentComplete ? Colors.green : Colors.red),
            )
                : null,
            onTap: () {
              if (!isSent && letter.date.isAfter(now)) {
                _showAlertDialog(context);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LetterDetailView(
                      letter: letter,
                      senderName: senderName,
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('편지를 읽을 수 없습니다'),
        content: Text('아직 수신 시간이 되지 않았습니다.'),
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
