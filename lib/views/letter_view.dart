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
          _buildLetterList(letterViewModel.receivedLetters, letterViewModel),
          _buildLetterList(letterViewModel.sentLetters, letterViewModel),
        ],
      ),
    );
  }

  Widget _buildLetterList(List<Letter?>? letters, LetterViewModel letterViewModel) {
    if (letters == null || letters.isEmpty) {
      return Center(child: Text('No letters found'));
    }

    return ListView.builder(
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        if (letter == null) return SizedBox.shrink(); // Null safety check
        final senderName = letterViewModel.getSenderName(letter.senderId);

        return ListTile(
          title: Text(letter.title ?? 'No Title'),
          subtitle: Text('From: $senderName\n${letter.date?.toLocal() ?? ''}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LetterDetailView(
                  letter: letter,
                  senderName: senderName,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
