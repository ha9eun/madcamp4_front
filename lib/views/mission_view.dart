import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import 'package:provider/provider.dart';
import '../view_models/mission_view_model.dart';
import 'package:intl/intl.dart';
import 'mission_edit_modal.dart';

class MissionView extends StatefulWidget {
  @override
  _MissionViewState createState() => _MissionViewState();
}

class _MissionViewState extends State<MissionView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<MissionViewModel>(context, listen: false).fetchMissions()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mission'),
      ),
      body: Consumer<MissionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.missions == null || viewModel.missions!.isEmpty) {
            return Center(child: Text('No missions available.'));
          }

          return ListView.builder(
            itemCount: viewModel.missions!.length,
            itemBuilder: (context, index) {
              final mission = viewModel.missions![index];
              return MissionCard(
                mission: mission,
                onEdit: () {
                  showDialog(
                    context: context,
                    builder: (context) => MissionEditModal(
                      missionId: mission.id,
                      currentTitle: mission.mission,
                      viewModel: viewModel,
                    ),
                  );
                },
                onDelete: () => viewModel.deleteMission(mission.id),
              );
            },
          );
        },
      ),
    );
  }
}

class MissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MissionCard({
    Key? key,
    required this.mission,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mission.mission,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Date: ${DateFormat('yyyy-MM-dd').format(mission.date.toLocal())}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onEdit,
                  child: Text('Edit'),
                ),
                TextButton(
                  onPressed: onDelete,
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
