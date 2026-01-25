import 'package:birthday_connector/models/user_profile.dart';

class Letter {
  final String id;
  final String senderId;
  final String recipientId;
  final String subject;
  final String content;
  final DateTime sentAt;
  final DateTime canOpenAt;
  final bool isOpened;
  final DateTime? openedAt;
  final UserProfile? sender;
  final UserProfile? recipient;

  Letter({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.subject,
    required this.content,
    required this.sentAt,
    required this.canOpenAt,
    this.isOpened = false,
    this.openedAt,
    this.sender,
    this.recipient,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      recipientId: json['recipient_id'] as String,
      subject: json['subject'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      canOpenAt: DateTime.parse(json['can_open_at'] as String),
      isOpened: json['is_opened'] as bool? ?? false,
      openedAt: json['opened_at'] != null 
          ? DateTime.parse(json['opened_at'] as String) 
          : null,
      sender: json['sender'] != null 
          ? UserProfile.fromJson(json['sender']) 
          : null,
      recipient: json['recipient'] != null 
          ? UserProfile.fromJson(json['recipient']) 
          : null,
    );
  }

  bool get canBeOpened => DateTime.now().isAfter(canOpenAt);
  
  Duration get timeUntilCanOpen {
    if (canBeOpened) return Duration.zero;
    return canOpenAt.difference(DateTime.now());
  }
}