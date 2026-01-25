class HistoricalEvent {
  final int id;
  final DateTime eventDate; 
  final String title;
  final String description;
  final String category;

  HistoricalEvent({
    required this.id,
    required this.eventDate,
    required this.title,
    required this.description,
    required this.category,
  });

  int get month => eventDate.month;
  int get day => eventDate.day;
  int get year => eventDate.year;

  factory HistoricalEvent.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      if (json['event_date'] != null) {
        final dateStr = json['event_date'].toString();
        if (dateStr.length == 10 && !dateStr.contains('T')) {
          parsedDate = DateTime.parse('${dateStr}T00:00:00.000Z');
        } else {
          parsedDate = DateTime.parse(dateStr);
        }
      } else {
        final month = int.tryParse(json['month']?.toString() ?? '1') ?? 1;
        final day = int.tryParse(json['day']?.toString() ?? '1') ?? 1;
        final year = int.tryParse(json['year']?.toString() ?? '2000') ?? 2000;
        parsedDate = DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing event_date: ${json['event_date']} - $e');
      final month = int.tryParse(json['month']?.toString() ?? '1') ?? 1;
      final day = int.tryParse(json['day']?.toString() ?? '1') ?? 1;
      final year = int.tryParse(json['year']?.toString() ?? '2000') ?? 2000;
      parsedDate = DateTime(year, month, day);
    }

    return HistoricalEvent(
      id: int.tryParse(json['id'].toString()) ?? 0,
      eventDate: parsedDate,
      title: json['title']?.toString() ?? 'Bez tytułu',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_date': eventDate.toIso8601String().split('T')[0],
      'year': year,
      'month': month,
      'day': day,
      'title': title,
      'description': description,
      'category': category,
    };
  }

  String get formattedDate => '$day.$month.$year';
  String get yearOnly => year.toString();
}