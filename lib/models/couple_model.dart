import 'package:couple/models/schedule_model.dart';
import 'anniversary_model.dart';

class Couple {
  String partnerNickname;
  List<Anniversary> anniversaries;
  List<Schedule> schedules;
  int daysSinceStart;

  Couple({
    required this.partnerNickname,
    required this.anniversaries,
    required this.schedules,
    required this.daysSinceStart,
  });

  factory Couple.fromJson(Map<String, dynamic> json, String myNickname) {
    String partnerNickname = json['user1Nickname'] == myNickname
        ? json['user2Nickname']
        : json['user1Nickname'];

    return Couple(
      partnerNickname: partnerNickname,
      anniversaries: json['anniversaries'] != null
          ? (json['anniversaries'] as List)
          .map((item) => Anniversary.fromJson(item))
          .toList()
          : [],
      schedules: json['schedules'] != null
          ? (json['schedules'] as List)
          .map((item) => Schedule.fromJson(item))
          .toList()
          : [],
      daysSinceStart: json['daysSinceStart'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partnerNickname': partnerNickname,
      'anniversaries': anniversaries.map((item) => item.toJson()).toList(),
      'schedules': schedules.map((item) => item.toJson()).toList(),
      'daysSinceStart': daysSinceStart,
    };
  }
}
