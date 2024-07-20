import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/couple_view_model.dart';
import '../view_models/user_view_model.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Provider.of<CoupleViewModel>(context, listen: false).fetchCoupleInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final coupleViewModel = Provider.of<CoupleViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: coupleViewModel.isLoading
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
                    text: '${coupleViewModel.couple!.partnerNickname}',
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
          // 캘린더 위젯
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
          ),
        ],
      ),
    );
  }
}
