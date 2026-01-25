class HistoricalEvent {
  final String id;
  final int month;
  final int day;
  final int? year;
  final String title;
  final String? description;
  final String? category;

  HistoricalEvent({
    required this.id,
    required this.month,
    required this.day,
    this.year,
    required this.title,
    this.description,
    this.category,
  });

  factory HistoricalEvent.fromJson(Map<String, dynamic> json) {
    return HistoricalEvent(
      id: json['id'],
      month: json['month'],
      day: json['day'],
      year: json['year'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'day': day,
      'year': year,
      'title': title,
      'description': description,
      'category': category,
    };
  }
}