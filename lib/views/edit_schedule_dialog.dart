import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';
import '../view_models/couple_view_model.dart';

class EditScheduleDialog extends StatefulWidget {
  final Schedule schedule;

  EditScheduleDialog({required this.schedule});

  @override
  _EditScheduleDialogState createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends State<EditScheduleDialog> {
  late TextEditingController _titleController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.schedule.title);
    _selectedDate = widget.schedule.date;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  initialDate: _selectedDate,
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
                      "${_selectedDate}".split(' ')[0],
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
            if (_titleController.text.isNotEmpty) {
              try {
                await Provider.of<CoupleViewModel>(context, listen: false)
                    .updateSchedule(widget.schedule.id, _selectedDate, _titleController.text);
                Navigator.of(context).pop();
              } catch (e) {
                print('Failed to update schedule: $e');
              }
            }
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}
