class FamousBirthday {
  final String name;
  final DateTime birthDate;
  final String? profession;
  final String? description;
  final String? imageUrl;

  FamousBirthday({
    required this.name,
    required this.birthDate,
    this.profession,
    this.description,
    this.imageUrl,
  });

  String get displayName {
    return name
        .split('_')
        .map((part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  factory FamousBirthday.fromJson(Map<String, dynamic> json) {
    return FamousBirthday(
      name: json['name'],
      birthDate: DateTime.parse(json['birth_date']),
      profession: json['profession'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }
}
