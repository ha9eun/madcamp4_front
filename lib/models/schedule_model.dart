// models/schedule_model.dart
class Schedule {
  final String id;
  final DateTime date;
  final String title;

  Schedule({
    required this.id,
    required this.date,
    required this.title,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['_id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date.toIso8601String(),
      'title': title,
    };
  }
}
