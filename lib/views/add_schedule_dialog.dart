import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/couple_view_model.dart';

class AddScheduleDialog extends StatefulWidget {
  @override
  _AddScheduleDialogState createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),//local
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? "${_selectedDate}".split(' ')[0]//날짜부분만
                          : 'Select Date',
                      style: TextStyle(color: Colors.black54),
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_titleController.text.isNotEmpty && _selectedDate != null) {
              try {
                await Provider.of<CoupleViewModel>(context, listen: false)
                    .addSchedule(_selectedDate!, _titleController.text);
                Navigator.of(context).pop();
              } catch (e) {
                print('Failed to add schedule: $e');
              }
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
