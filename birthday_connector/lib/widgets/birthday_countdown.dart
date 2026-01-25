import 'package:flutter/material.dart';

class BirthdayCountdownCard extends StatelessWidget {
  final DateTime birthDate;

  const BirthdayCountdownCard({super.key, required this.birthDate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    DateTime nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }

    final daysUntil = nextBirthday.difference(now).inDays;
    final isToday = daysUntil == 0;

    return Card(
      elevation: 6,
      shadowColor: colorScheme.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isToday
                ? [
                    colorScheme.primary,
                    colorScheme.secondary,
                    colorScheme.tertiary,
                  ]
                : [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isToday
                      ? colorScheme.onPrimary.withOpacity(0.2)
                      : colorScheme.surface.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isToday ? Icons.celebration : Icons.cake_outlined,
                  size: 40,
                  color: isToday
                      ? colorScheme.onPrimary
                      : colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isToday ? '🎉 Happy Birthday! 🎉' : 'Your Next Birthday',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimaryContainer,
                    ),
                textAlign: TextAlign.center,
              ),
              if (!isToday) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$daysUntil',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 56,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      daysUntil == 1 ? 'day' : 'days',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_getMonthName(nextBirthday.month)} ${nextBirthday.day}, ${nextBirthday.year}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Text(
                  'Wishing you an amazing day! 🎂',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
