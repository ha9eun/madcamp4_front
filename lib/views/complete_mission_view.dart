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

    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Mission'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _diaryController,
                decoration: InputDecoration(labelText: 'Diary'),
                maxLines: 5,
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _selectedFiles.map((file) {
                  return Stack(
                    children: [
                      Image.file(
                        file,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
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
              SizedBox(height: 20),
              ElevatedButton(
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
                child: Text('Complete Mission'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
