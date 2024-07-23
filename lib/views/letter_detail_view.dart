import 'package:flutter/material.dart';
import '../models/letter_model.dart';

class LetterDetailView extends StatelessWidget {
  final Letter letter;
  final String senderName;

  LetterDetailView({required this.letter, required this.senderName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(letter.title ?? 'No Title'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From: $senderName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${letter.date?.toLocal() ?? ''}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              letter.content ?? 'No Content',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            if (letter.photoUrls != null && letter.photoUrls!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: letter.photoUrls!.map((url) => Image.network(url)).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
