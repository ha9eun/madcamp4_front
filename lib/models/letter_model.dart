class Letter {
  final String id;
  final String title;
  final String content;
  final List<String>? photoUrls;
  final DateTime date;
  final String senderId;

  Letter({
    required this.id,
    required this.title,
    required this.content,
    this.photoUrls,
    required this.date,
    required this.senderId,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['_id'],
      title: json['title'],
      content: json['content'],
      photoUrls: json['photos'] != null ? List<String>.from(json['photos']) : null,
      date: DateTime.parse(json['date']),
      senderId: json['senderId'],
    );
  }

}