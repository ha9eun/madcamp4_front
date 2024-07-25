import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/anniversary_model.dart';
import '../models/schedule_model.dart';
import '../view_models/couple_view_model.dart';
import '../view_models/user_view_model.dart';
import '../view_models/login_view_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_schedule_dialog.dart';
import 'edit_schedule_dialog.dart';

class CalendarView extends StatefulWidget {
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _selectedDay = DateTime.now().toLocal();
  DateTime _focusedDay = DateTime.now().toLocal();
  List<dynamic> _selectedEvents = [];

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await Provider.of<LoginViewModel>(context, listen: false).logout(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Consumer<CoupleViewModel>(
        builder: (context, coupleViewModel, child) {
          _selectedEvents = [
            ..._getEventsForDay(_selectedDay, coupleViewModel.couple?.anniversaries ?? []),
            ..._getSchedulesForDay(_selectedDay, coupleViewModel.couple?.schedules ?? []),
          ];

          return coupleViewModel.isLoading
              ? Center(child: CircularProgressIndicator())
              : coupleViewModel.couple == null
              ? Center(child: Text('Failed to load couple info'))
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: userViewModel.user?.nickname ?? '',
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                      WidgetSpan(
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      TextSpan(
                        text: ' ${coupleViewModel.couple!.partnerNickname}',
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                      TextSpan(
                        text: ' ${coupleViewModel.couple!.daysSinceStart}일째 연애중',
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedEvents = [
                        ..._getEventsForDay(selectedDay, coupleViewModel.couple!.anniversaries),
                        ..._getSchedulesForDay(selectedDay, coupleViewModel.couple!.schedules),
                      ];
                    });
                  },
                  eventLoader: (day) {
                    return [
                      ..._getEventsForDay(day, coupleViewModel.couple!.anniversaries),
                      ..._getSchedulesForDay(day, coupleViewModel.couple!.schedules),
                    ];
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isNotEmpty) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: events.map((event) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0.5),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: event is Anniversary ? Colors.red : Colors.blue,
                              ),
                            );
                          }).toList(),
                        );
                      }
                      return null;
                    },
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedEvents.length,
                  itemBuilder: (context, index) {
                    final event = _selectedEvents[index];
                    return ListTile(
                      leading: Icon(
                        event is Anniversary ? Icons.cake : Icons.event,
                        color: event is Anniversary ? Colors.red : Colors.blue,
                      ),
                      title: Text(event.title),
                      onLongPress: () {
                        if (event is Schedule) {
                          _showOptionsDialog(context, event);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddScheduleDialog(),
        ),
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, Schedule schedule) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context); // Close the options dialog
                showDialog(
                  context: context,
                  builder: (context) => EditScheduleDialog(schedule: schedule),
                ).then((_) {
                  final coupleViewModel = Provider.of<CoupleViewModel>(context, listen: false);
                  setState(() {
                    _selectedEvents = [
                      ..._getEventsForDay(_selectedDay, coupleViewModel.couple!.anniversaries),
                      ..._getSchedulesForDay(_selectedDay, coupleViewModel.couple!.schedules),
                    ];
                  });
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () async {
                Navigator.pop(context); // Close the options dialog
                await Provider.of<CoupleViewModel>(context, listen: false).deleteSchedule(schedule.id);
                setState(() {
                  final coupleViewModel = Provider.of<CoupleViewModel>(context, listen: false);
                  _selectedEvents = [
                    ..._getEventsForDay(_selectedDay, coupleViewModel.couple!.anniversaries),
                    ..._getSchedulesForDay(_selectedDay, coupleViewModel.couple!.schedules),
                  ];
                });
              },
            ),
          ],
        );
      },
    );
  }

  List<dynamic> _getEventsForDay(DateTime day, List<Anniversary> anniversaries) {
    return anniversaries.where((anniversary) {
      return anniversary.date.year == day.year &&
          anniversary.date.month == day.month &&
          anniversary.date.day == day.day;
    }).toList();
  }

  List<dynamic> _getSchedulesForDay(DateTime day, List<Schedule> schedules) {
    return schedules.where((schedule) {
      return schedule.date.year == day.year &&
          schedule.date.month == day.month &&
          schedule.date.day == day.day;
    }).toList();
  }
}
