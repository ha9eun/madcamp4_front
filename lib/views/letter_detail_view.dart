import 'package:flutter/material.dart';
import '../models/letter_model.dart';
import 'write_letter_view.dart';

class LetterDetailView extends StatelessWidget {
  final Letter letter;
  final String senderName;

  LetterDetailView({required this.letter, required this.senderName});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canEdit = letter.date.isAfter(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(letter.title ?? 'No Title'),
        actions: [
          if (canEdit)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WriteLetterView(letter: letter),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
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
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: letter.photoUrls!.map((url) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(url),
                                  fit: BoxFit.contain,
                                ),
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
      ),
    );
  }
}
