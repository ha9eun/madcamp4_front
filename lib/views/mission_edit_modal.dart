import 'package:flutter/material.dart';
import '../view_models/mission_view_model.dart';

class MissionEditModal extends StatelessWidget {
  final String missionId;
  final String currentTitle;
  final MissionViewModel viewModel;

  const MissionEditModal({
    Key? key,
    required this.missionId,
    required this.currentTitle,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: currentTitle);
    return AlertDialog(
      title: Text('Edit Mission'),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: 'Enter new title'),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();  // Close the dialog without doing anything
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            final newTitle = controller.text;
            if (newTitle.isNotEmpty) {
              viewModel.updateMission(missionId, newTitle, DateTime.now());  // Update the mission
            }
            Navigator.of(context).pop();  // Close the dialog
          },
        ),
      ],
    );
  }
}
