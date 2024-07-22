class Anniversary {
  String title;
  DateTime date;

  Anniversary({
    required this.title,
    required this.date,
  });

  factory Anniversary.fromJson(Map<String, dynamic> json) {
    return Anniversary(
      title: json['title'] ?? '',
      date: DateTime.parse(json['date']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
    };
  }
}