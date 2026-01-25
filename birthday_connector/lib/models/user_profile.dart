class UserProfile {
  final String id;
  final String username;
  final String email;
  final DateTime birthDate;
  final String? bio;
  final String? interests;
  final String? iceBreakerQuestion;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.birthDate,
    this.bio,
    this.interests,
    this.iceBreakerQuestion,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      birthDate: _parseDateTime(json['birth_date']),
      bio: json['bio'] as String?,
      interests: json['interests'] as String?,
      iceBreakerQuestion: json['ice_breaker_question'] as String?,
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is DateTime) return value;

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Błąd parsowania daty: $value');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? birthDate,
    String? bio,
    String? interests,
    String? iceBreakerQuestion,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      iceBreakerQuestion: iceBreakerQuestion ?? this.iceBreakerQuestion,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
