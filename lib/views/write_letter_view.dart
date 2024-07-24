import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../view_models/letter_view_model.dart';
import 'package:intl/intl.dart';
import '../models/letter_model.dart';

class WriteLetterView extends StatefulWidget {
  final Letter? letter;

  WriteLetterView({this.letter});

  @override
  _WriteLetterViewState createState() => _WriteLetterViewState();
}

class _WriteLetterViewState extends State<WriteLetterView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  List<File> _selectedFiles = [];
  List<String> _existingPhotos = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.letter != null) {
      _titleController.text = widget.letter!.title;
      _contentController.text = widget.letter!.content;
      _selectedDate = widget.letter!.date;
      _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!);
      _existingPhotos = List<String>.from(widget.letter!.photoUrls ?? []);
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

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final letterViewModel = Provider.of<LetterViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.letter == null ? 'Write Letter' : 'Edit Letter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
              GestureDetector(
                onTap: () => _selectDateTime(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Select Date and Time',
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _existingPhotos.map((url) {
                  return Stack(
                    children: [
                      Image.network(
                        url,
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
                              _existingPhotos.remove(url);
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
                  if (_titleController.text.isNotEmpty &&
                      _contentController.text.isNotEmpty &&
                      _selectedDate != null) {
                    if (widget.letter == null) {
                      await letterViewModel.addLetter(
                        title: _titleController.text,
                        content: _contentController.text,
                        date: _selectedDate!,
                        photos: _selectedFiles,
                      );
                    } else {
                      await letterViewModel.updateLetter(
                        id: widget.letter!.id,
                        title: _titleController.text,
                        content: _contentController.text,
                        date: _selectedDate!,
                        newPhotos: _selectedFiles,
                        existingPhotoUrls: _existingPhotos,
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.letter == null ? 'Send' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
