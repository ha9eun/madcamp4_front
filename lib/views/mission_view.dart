import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import 'package:provider/provider.dart';
import '../view_models/mission_view_model.dart';
import 'package:intl/intl.dart';
import 'complete_mission_view.dart';
import 'mission_detail_view.dart';

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
    final themeColor = Color(0xFFCD001F);

    return Scaffold(
      body: SafeArea(
        child: Consumer<MissionViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator(color: themeColor));
            }

            if (viewModel.missions == null || viewModel.missions!.isEmpty) {
              return Center(child: Text('사용 가능한 미션이 없습니다.'));
            }

            final ongoingMissions = viewModel.missions!.where((mission) => mission.diary == null).toList();
            final completedMissions = viewModel.missions!.where((mission) => mission.diary != null).toList();

            return ListView(
              children: [
                if (ongoingMissions.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      '진행 중인 미션',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...ongoingMissions.map((mission) => MissionCard(
                    mission: mission,
                    onComplete: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompleteMissionView(missionId: mission.id),
                        ),
                      );
                    },
                  )),
                ],
                if (completedMissions.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      '완료된 미션',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...completedMissions.map((mission) => MissionCard(
                    mission: mission,
                    onComplete: () {}, // Completed missions don't need a complete button
                  )),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class MissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onComplete;

  const MissionCard({
    Key? key,
    required this.mission,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(0xFFCD001F);

    return GestureDetector(
      onTap: mission.diary != null
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MissionDetailView(mission: mission),
          ),
        );
      }
          : null,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.all(12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mission.mission,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                '${DateFormat('yyyy년 MM월 dd일').format(mission.date.toLocal())}',
                style: TextStyle(fontSize: 13.0, color: Colors.grey[600]),
              ),
              if (mission.diary == null) ...[
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    ),
                    child: Text('미션 완료', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
