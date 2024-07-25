import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mission_model.dart';

class MissionDetailView extends StatelessWidget {
  final Mission mission;

  MissionDetailView({required this.mission});

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(0xFFCD001F);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        '미션 상세',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // IconButton의 크기와 동일한 너비를 추가하여 균형 맞추기
                  ],
                ),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10.0,
                        spreadRadius: 5.0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.mission,
                        style: TextStyle(
                          fontSize: 19.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        '${DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(mission.date.toLocal())}',
                        style: TextStyle(fontSize: 16.0, color: Colors.black54),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        mission.diary ?? '일지가 없습니다.',
                        style: TextStyle(fontSize: 16.0, color: Colors.black87),
                      ),
                      SizedBox(height: 16.0),
                      if (mission.photos != null && mission.photos!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: mission.photos!.map((url) {
                                return GestureDetector(
                                  onTap: () {
                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel: MaterialLocalizations.of(context)
                                          .modalBarrierDismissLabel,
                                      barrierColor: Colors.black54,
                                      transitionDuration: const Duration(milliseconds: 200),
                                      pageBuilder: (BuildContext context, Animation animation,
                                          Animation secondaryAnimation) {
                                        return Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(url),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            width: MediaQuery.of(context).size.width * 0.9,
                                            height: MediaQuery.of(context).size.height * 0.9,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      url,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
