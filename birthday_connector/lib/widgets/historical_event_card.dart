import 'package:birthday_connector/models/historical_event.dart';
import 'package:flutter/material.dart';

class HistoricalEventCard extends StatelessWidget {
  final List<HistoricalEvent> events;

  const HistoricalEventCard({super.key, required this.events});

  String _formatText(String text) {
    if (text.isEmpty) return text;
    String formatted = text.replaceAll('_', ' ');
    if (formatted.length > 1) {
      return '${formatted[0].toUpperCase()}${formatted.substring(1)}';
    }
    return formatted.toUpperCase();
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (events.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "No historical events for this date.",
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    return Column(
      children: events.map((event) {
        final yearsAgo = DateTime.now().year - event.year;
        

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.2), 
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.year.toString(),
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$yearsAgo years ago',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatText(event.title), 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatText(event.description),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}