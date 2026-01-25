import 'package:birthday_connector/models/historical_event.dart';
import 'package:flutter/material.dart';

class HistoricalEventCard extends StatelessWidget {
  final HistoricalEvent event;

  const HistoricalEventCard({super.key, required this.event});

  Color _getCategoryColor(BuildContext context, String? category) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (category) {
      case 'science':
        return Colors.blue;
      case 'politics':
        return Colors.red;
      case 'culture':
        return Colors.purple;
      case 'technology':
        return Colors.green;
      case 'sports':
        return Colors.orange;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final yearsAgo = DateTime.now().year - event.year!;
    final categoryColor = _getCategoryColor(context, event.category);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.year.toString(),
                    style: TextStyle(
                      color: categoryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$yearsAgo years ago',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              event.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
