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
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            birthday.displayName.isNotEmpty
                ? birthday.displayName.substring(0, 1).toUpperCase()
                : '?',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          birthday.displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (birthday.profession != null && birthday.profession!.isNotEmpty)
              Text(
                birthday.profession!,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              '$age years old',
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
