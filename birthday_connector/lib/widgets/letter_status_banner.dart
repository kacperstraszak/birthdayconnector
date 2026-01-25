import 'package:birthday_connector/models/letter.dart';
import 'package:flutter/material.dart';

class LetterStatusBanner extends StatefulWidget {
  final Letter letter;

  const LetterStatusBanner({super.key, required this.letter});

  @override
  State<LetterStatusBanner> createState() => _LetterStatusBannerState();
}

class _LetterStatusBannerState extends State<LetterStatusBanner> {
  @override
  void initState() {
    super.initState();
    if (!widget.letter.canBeOpened) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.letter.isOpened) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Opened ${_formatTimeAgo(widget.letter.openedAt!)}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.letter.canBeOpened) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_open,
                size: 16, color: colorScheme.onPrimaryContainer),
            const SizedBox(width: 8),
            Text(
              'Ready to open!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      );
    }

    final timeLeft = widget.letter.timeUntilCanOpen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_clock,
              size: 16, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Text(
            'Opens in ${_formatDuration(timeLeft)}',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
