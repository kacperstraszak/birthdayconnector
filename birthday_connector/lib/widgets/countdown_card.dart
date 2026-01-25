import 'package:birthday_connector/models/countdown_event.dart';
import 'package:flutter/material.dart';

class CountdownCard extends StatelessWidget {
  final CountdownEvent event;

  const CountdownCard({super.key, required this.event});

  static const Map<String, IconData> _iconMap = {
    'wb_twilight': Icons.wb_twilight,
    'card_giftcard': Icons.card_giftcard,
    'stars': Icons.stars,
    'celebration': Icons.celebration,
  };

  IconData _getIcon() {
    return _iconMap[event.icon] ?? Icons.event;
  }

  String _formatText(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  String _getTimeUntil() {
    final now = DateTime.now();
    final dateNow = DateTime(now.year, now.month, now.day);
    final dateEvent = DateTime(
        event.eventDate.year, event.eventDate.month, event.eventDate.day);

    final diff = dateEvent.difference(dateNow).inDays;

    if (diff == 0) return 'Today!';
    if (diff == 1) return 'Tomorrow';
    if (diff < 0) return 'Past';
    return 'in $diff days';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeUntil = _getTimeUntil();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(),
                color: colorScheme.onPrimaryContainer,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatText(event.title),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      timeUntil,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
