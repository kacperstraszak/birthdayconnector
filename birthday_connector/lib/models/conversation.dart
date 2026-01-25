import 'package:birthday_connector/models/user_profile.dart';

class Conversation {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile? user1;
  final UserProfile? user2;

  Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    required this.updatedAt,
    this.user1,
    this.user2,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      user1Id: json['user1_id'] as String,
      user2Id: json['user2_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user1: json['user1'] != null ? UserProfile.fromJson(json['user1']) : null,
      user2: json['user2'] != null ? UserProfile.fromJson(json['user2']) : null,
    );
  }

  UserProfile? getOtherUser(String currentUserId) {
    if (user1Id == currentUserId) return user2;
    if (user2Id == currentUserId) return user1;
    return null;
  }

  String getOtherUserId(String currentUserId) {
    return user1Id == currentUserId ? user2Id : user1Id;
  }
}
