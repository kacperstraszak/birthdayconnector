import 'package:birthday_connector/models/letter.dart';
import 'package:birthday_connector/providers/auth_provider.dart';
import 'package:birthday_connector/providers/messages_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class LetterDetailScreen extends ConsumerStatefulWidget {
  final Letter letter;

  const LetterDetailScreen({
    super.key,
    required this.letter,
  });

  @override
  ConsumerState<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends ConsumerState<LetterDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isOpening = false;
  bool _hasOpened = false;

  @override
  void initState() {
    super.initState();
    _hasOpened = widget.letter.isOpened;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openLetter() async {
    if (!widget.letter.canBeOpened || widget.letter.isOpened) return;

    setState(() => _isOpening = true);

    final success = await ref.read(lettersProvider.notifier).openLetter(widget.letter.id);

    if (success && mounted) {
      setState(() {
        _hasOpened = true;
        _isOpening = false;
      });
      _controller.forward();
      
      // Odśwież listę wiadomości w tle
      ref.read(lettersProvider.notifier).loadLetters();
    } else if (mounted) {
      setState(() => _isOpening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to open letter'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = ref.watch(authProvider).user?.id;
    final isReceived = widget.letter.recipientId == currentUserId;
    final otherUser = isReceived ? widget.letter.sender : widget.letter.recipient;

    return Scaffold(
      appBar: AppBar(
        title: Text(isReceived ? 'Letter from ${otherUser?.username}' : 'Letter to ${otherUser?.username}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Icon(
                      _hasOpened ? Icons.drafts : Icons.mail,
                      size: 80,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.letter.subject,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sent ${DateFormat.yMMMd().add_jm().format(widget.letter.sentAt)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            if (isReceived && !_hasOpened) ...[
              const SizedBox(height: 24),
              _buildStatusSection(colorScheme),
            ],

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(24),
              child: _buildLetterContent(colorScheme, isReceived),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(ColorScheme colorScheme) {
    if (widget.letter.canBeOpened) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_open,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This letter is ready to be opened!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isOpening ? null : _openLetter,
                icon: _isOpening
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.mark_email_read),
                label: Text(_isOpening ? 'Opening...' : 'Open Letter'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final timeLeft = widget.letter.timeUntilCanOpen;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.lock_clock,
              size: 48,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(height: 12),
            Text(
              'Letter is Sealed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can open it in:',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDuration(timeLeft),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Opens at: ${DateFormat.yMMMd().add_jm().format(widget.letter.canOpenAt)}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterContent(ColorScheme colorScheme, bool isReceived) {
    if (isReceived && !_hasOpened) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.visibility_off,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Letter content is hidden',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Open the letter to read it',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${isReceived ? 'From' : 'To'}: ${widget.letter.sender?.username ?? widget.letter.recipient?.username ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              widget.letter.content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: colorScheme.onSurface,
              ),
            ),
            if (_hasOpened && isReceived && widget.letter.openedAt != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Opened ${DateFormat.yMMMd().add_jm().format(widget.letter.openedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours hour${hours != 1 ? 's' : ''} ${minutes}min';
    }
    return '$minutes minute${minutes != 1 ? 's' : ''}';
  }
}