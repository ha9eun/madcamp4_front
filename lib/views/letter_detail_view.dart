import 'package:flutter/material.dart';
import '../models/letter_model.dart';

class LetterDetailView extends StatelessWidget {
  final Letter letter;
  final String senderName;

  const LetterDetailView({
    Key? key,
    required this.letter,
    required this.senderName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Letter Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              letter.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'From: $senderName',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Date: ${letter.date.toLocal()}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              letter.content,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            if (letter.photoUrls != null && letter.photoUrls!.isNotEmpty)
              Text(
                'Photos:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            if (letter.photoUrls != null && letter.photoUrls!.isNotEmpty)
              SizedBox(height: 10),
            if (letter.photoUrls != null && letter.photoUrls!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: letter.photoUrls!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(letter.photoUrls![index]),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
