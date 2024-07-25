import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/letter_model.dart';
import 'write_letter_view.dart';
import '../view_models/letter_view_model.dart';

class LetterDetailView extends StatelessWidget {
  final Letter letter;
  final String senderName;

  LetterDetailView({required this.letter, required this.senderName});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canEdit = letter.date.isAfter(now);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/crumpled.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Consumer<LetterViewModel>(
            builder: (context, letterViewModel, child) {
              final updatedLetter = letterViewModel.sentLetters?.firstWhere(
                    (l) => l.id == letter.id,
                orElse: () => letter,
              ) ?? letter;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            updatedLetter.title ?? 'No Title',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (canEdit)
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.black),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WriteLetterView(letter: updatedLetter),
                                ),
                              ).then((_) {
                                letterViewModel.fetchLetters(); // 편지 수정 후 데이터 갱신
                              });
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'From: $senderName',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(updatedLetter.date.toLocal())}',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            spreadRadius: 2.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        updatedLetter.content,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (updatedLetter.photoUrls != null && updatedLetter.photoUrls!.isNotEmpty)
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: updatedLetter.photoUrls!.map((url) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent, // 배경색 투명하게 설정
                                    child: Center(
                                      child: AspectRatio(
                                        aspectRatio: 1, // 이미지 비율 유지
                                        child: Image.network(url),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Image.network(
                              url,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
