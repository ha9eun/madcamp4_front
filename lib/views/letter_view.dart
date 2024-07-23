import 'package:couple/views/write_letter_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/letter_model.dart';
import '../view_models/letter_view_model.dart';
import '../view_models/couple_view_model.dart';
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
    WidgetsBinding.instance?.addPostFrameCallback((_) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Letters'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '받은 편지함'),
            Tab(text: '보낸 편지함'),
          ],
        ),
      ),
      body: letterViewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildLetterList(letterViewModel.receivedLetters, letterViewModel, isSent: false),
          _buildLetterList(letterViewModel.sentLetters, letterViewModel, isSent: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WriteLetterView()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildLetterList(List<Letter?>? letters, LetterViewModel letterViewModel, {required bool isSent}) {
    if (letters == null || letters.isEmpty) {
      return Center(child: Text('No letters found'));
    }

    return ListView.builder(
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        if (letter == null) return SizedBox.shrink(); // Null safety check
        final senderName = letterViewModel.getSenderName(letter.senderId);
        final now = DateTime.now();
        final isSentComplete = letter.date.isBefore(now);

        return ListTile(
          title: Text(letter.title ?? 'No Title'),
          subtitle: Text('From: $senderName\n${letter.date?.toLocal() ?? ''}'),
          trailing: isSent
              ? Text(isSentComplete ? '전송 완료' : '전송 전')
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
