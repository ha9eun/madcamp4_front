class User {
  String id;
  String username;
  String nickname;
  String coupleId;

  User({
    required this.id,
    required this.username,
    required this.nickname,
    required this.coupleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      nickname: json['nickname'],
      coupleId: json['coupleId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'nickname': nickname,
      'coupleId': coupleId,
    };
  }
}