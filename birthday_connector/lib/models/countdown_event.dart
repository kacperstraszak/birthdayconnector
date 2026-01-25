class CountdownEvent {
  final String id;
  final String title;
  final DateTime eventDate;
  final String? description;
  final String? icon;

  CountdownEvent({
    required this.id,
    required this.title,
    required this.eventDate,
    this.description,
    this.icon,
  });

  factory CountdownEvent.fromJson(Map<String, dynamic> json) {
    return CountdownEvent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Event',
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'].toString())
          : DateTime.now(),
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
    );
  }
}
