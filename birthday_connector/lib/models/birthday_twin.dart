import 'package:birthday_connector/models/user_profile.dart';

class BirthdayTwin {
  final String id;
  final String username;
  final String? bio;
  final String? interests;
  final String? avatarUrl;
  final int age;
  final String? iceBreakerQuestion;

  BirthdayTwin({
    required this.id,
    required this.username,
    this.bio,
    this.interests,
    this.avatarUrl,
    required this.age,
    this.iceBreakerQuestion,
  });

  factory BirthdayTwin.fromJson(Map<String, dynamic> json) {
    return BirthdayTwin(
      id: json['id'] as String,
      username: json['username'] as String,
      bio: json['bio'] as String?,
      interests: json['interests'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      age: json['age'] is int ? json['age'] : int.tryParse(json['age'].toString()) ?? 0,
      iceBreakerQuestion: json['ice_breaker_question'] as String?,
    );
  }

  UserProfile toUserProfile() {
    return UserProfile(
      id: id,
      username: username,
      email: '', 
      birthDate: DateTime.now(), 
      bio: bio,
      interests: interests,
      iceBreakerQuestion: iceBreakerQuestion,
      createdAt: DateTime.now(),
    );
  }
}