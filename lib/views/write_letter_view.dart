import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../view_models/letter_view_model.dart';
import 'package:intl/intl.dart';

class WriteLetterView extends StatefulWidget {
  @override
  _WriteLetterViewState createState() => _WriteLetterViewState();
}

class _WriteLetterViewState extends State<WriteLetterView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<File> _selectedFiles = [];

  final ImagePicker _picker = ImagePicker();

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
        initialTime: _selectedTime ?? TimeOfDay.now(),
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
        title: Text('Write Letter'),
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
                children: _selectedFiles.map((file) {
                  return Image.file(
                    file,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_titleController.text.isNotEmpty &&
                      _contentController.text.isNotEmpty &&
                      _selectedDate != null) {
                    await letterViewModel.addLetter(
                      title: _titleController.text,
                      content: _contentController.text,
                      date: _selectedDate!,
                      photos: _selectedFiles,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
