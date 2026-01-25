import 'package:flutter/material.dart';
import 'package:birthday_connector/models/famous_birthday.dart';

class FamousBirthdayCard extends StatelessWidget {
  final FamousBirthday birthday;

  const FamousBirthdayCard({super.key, required this.birthday});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final age = DateTime.now().year - birthday.birthDate.year;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            birthday.displayName,
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          birthday.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (birthday.profession != null) Text(birthday.profession!),
            Text(
              'Born ${birthday.birthDate.year} (would be $age)',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        isThreeLine: birthday.profession != null,
      ),
    );
  }
}
