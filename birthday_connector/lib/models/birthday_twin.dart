class BirthdayTwin {
  final String id;
  final String username;
  final String? bio;
  final String? interests;
  final String? avatarUrl;
  final int age;

  BirthdayTwin({
    required this.id,
    required this.username,
    this.bio,
    this.interests,
    this.avatarUrl,
    required this.age,
  });

  factory BirthdayTwin.fromJson(Map<String, dynamic> json) {
    return BirthdayTwin(
      id: json['id'],
      username: json['username'],
      bio: json['bio'],
      interests: json['interests'],
      avatarUrl: json['avatar_url'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'bio': bio,
      'interests': interests,
      'avatar_url': avatarUrl,
      'age': age,
    };
  }
}