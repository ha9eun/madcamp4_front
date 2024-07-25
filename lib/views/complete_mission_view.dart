import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../view_models/mission_view_model.dart';
import '../models/mission_model.dart';

class CompleteMissionView extends StatefulWidget {
  final String missionId;

  CompleteMissionView({required this.missionId});

  @override
  _CompleteMissionViewState createState() => _CompleteMissionViewState();
}

class _CompleteMissionViewState extends State<CompleteMissionView> {
  final TextEditingController _diaryController = TextEditingController();
  List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final missionViewModel = Provider.of<MissionViewModel>(context, listen: false);
    Mission? mission = missionViewModel.missions?.firstWhere((m) => m.id == widget.missionId);
    if (mission != null && mission.diary != null) {
      _diaryController.text = mission.diary!;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFiles.add(File(pickedFile.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final missionViewModel = Provider.of<MissionViewModel>(context, listen: false);
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
                        '미션 인증',
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
                Text(
                  '미션 일지 작성',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _diaryController,
                  decoration: InputDecoration(
                    labelText: '일지',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 5,
                ),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image, color: Colors.black),
                  label: Text('이미지 선택',
                  style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _selectedFiles.map((file) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFiles.remove(file);
                              });
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_diaryController.text.isNotEmpty) {
                        await missionViewModel.completeMission(
                          missionId: widget.missionId,
                          diary: _diaryController.text,
                          photos: _selectedFiles,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text('미션 완료'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
