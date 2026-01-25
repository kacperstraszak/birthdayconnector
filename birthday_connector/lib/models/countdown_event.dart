class CountdownEvent {
  final String id;
  final String title;
  final DateTime eventDate;
  final String? description;
  final String? icon;
  final bool isRecurring;
  final String? recurrenceType;

  CountdownEvent({
    required this.id,
    required this.title,
    required this.eventDate,
    this.description,
    this.icon,
    required this.isRecurring,
    this.recurrenceType,
  });

  factory CountdownEvent.fromJson(Map<String, dynamic> json) {
    return CountdownEvent(
      id: json['id'],
      title: json['title'],
      eventDate: DateTime.parse(json['event_date']),
      description: json['description'],
      icon: json['icon'],
      isRecurring: json['is_recurring'] ?? false,
      recurrenceType: json['recurrence_type'],
    );
  }

  Duration get timeUntil => eventDate.difference(DateTime.now());
  
  String get formattedTimeUntil {
    final duration = timeUntil;
    if (duration.isNegative) return 'Event passed';
    
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    if (days > 365) {
      final years = (days / 365).floor();
      final remainingDays = days % 365;
      return '$years year${years != 1 ? 's' : ''}, $remainingDays days';
    } else if (days > 0) {
      return '$days day${days != 1 ? 's' : ''}, $hours hour${hours != 1 ? 's' : ''}';
    } else if (hours > 0) {
      return '$hours hour${hours != 1 ? 's' : ''}, $minutes min';
    } else {
      return '$minutes minute${minutes != 1 ? 's' : ''}';
    }
  }
}