import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/letter_view_model.dart';

class LetterView extends StatefulWidget {
  @override
  _LetterViewState createState() => _LetterViewState();
}

class _LetterViewState extends State<LetterView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Provider.of<LetterViewModel>(context, listen: false).fetchLetters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final letterViewModel = Provider.of<LetterViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Letters'),
      ),
      body: letterViewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : letterViewModel.letters == null
          ? Center(child: Text('편지가 없습니다'))
          : ListView.builder(
        itemCount: letterViewModel.letters!.length,
        itemBuilder: (context, index) {
          final letter = letterViewModel.letters![index];
          final senderName = letterViewModel.getSenderName(letter.senderId);

          return ListTile(
            title: Text(letter.title),
            subtitle: Text('From: $senderName\n${letter.date.toLocal()}'),
            onTap: () {
              // 편지 내용 보기 화면으로 이동
            },
          );
        },
      ),
    );
  }
}
