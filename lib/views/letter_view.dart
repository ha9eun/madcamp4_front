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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // 추가된 여백
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WriteLetterView()),
            );
          },
          backgroundColor: Colors.white,
          child: Icon(Icons.edit, color: themeColor),
        ),
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
        final isSentComplete = letter.date.toLocal().isBefore(now);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GestureDetector(
            onTap: () {
              if (!isSent && letter.date.toLocal().isAfter(now)) {
                _showSnackBar(context, letter.date.toLocal());
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
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(double.infinity, 200),
                  painter: EnvelopePainter(),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/crumpled.jpg'), // 구겨진 종이 텍스처 이미지 추가
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4.0,
                          spreadRadius: 2.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          letter.title ?? 'No Title',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'From: $senderName',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(letter.date.toLocal()),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (isSent)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              isSentComplete ? '전송 완료' : '전송 전',
                              style: TextStyle(
                                fontSize: 14,
                                color: isSentComplete ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, DateTime date) {
    final formattedDate = DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(date);
    final snackBar = SnackBar(
      content: Text('$formattedDate에 공개됩니다!'),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class EnvelopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown[300]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.4); // 높이 40% 위치에서 시작
    path.lineTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.4); // 높이 40% 위치로 변경
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final lowerPath = Path();
    lowerPath.moveTo(0, size.height);
    lowerPath.lineTo(size.width * 0.5, size.height * 0.4); // 편지지가 살짝 보이도록 높이 조정
    lowerPath.lineTo(size.width, size.height);
    lowerPath.close();

    canvas.drawPath(lowerPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
