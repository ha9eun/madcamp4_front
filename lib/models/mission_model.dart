class Mission {
  final String id;
  final String coupleId;
  final String mission;
  final DateTime date;
  final List<String>? photos;
  final String? aiComment;
  final String? diary;

  Mission({
    required this.id,
    required this.coupleId,
    required this.mission,
    required this.date,
    this.photos,
    this.aiComment,
    this.diary,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['_id'],
      coupleId: json['coupleId'],
      mission: json['mission'],
      date: DateTime.parse(json['date']),
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      aiComment: json['aiComment'],
      diary: json['diary'],
    );
  }
}
