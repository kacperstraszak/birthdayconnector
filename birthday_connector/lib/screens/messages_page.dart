import 'package:birthday_connector/models/letter.dart';
import 'package:birthday_connector/providers/messages_provider.dart';
import 'package:birthday_connector/screens/birthday_twins.dart';
import 'package:birthday_connector/screens/letter_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lettersProvider.notifier).loadLetters();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lettersState = ref.watch(lettersProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final unreadCount = lettersState.receivedLetters
        .where((letter) => !letter.isOpened && letter.canBeOpened)
        .length;

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Received'),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: TextStyle(
                            color: colorScheme.onError,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Tab(text: 'Sent'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReceivedTab(lettersState, colorScheme),
                _buildSentTab(lettersState, colorScheme),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BirthdayTwinsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.people),
        label: const Text('Birthday Twins'),
      ),
    );
  }

  Widget _buildReceivedTab(LettersState state, ColorScheme colorScheme) {
    if (state.isLoading && state.receivedLetters.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.receivedLetters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Letters Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with your birthday twins!',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(lettersProvider.notifier).loadLetters();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.receivedLetters.length,
        itemBuilder: (context, index) {
          final letter = state.receivedLetters[index];
          return _LetterCard(
            letter: letter,
            isReceived: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LetterDetailScreen(letter: letter),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSentTab(LettersState state, ColorScheme colorScheme) {
    if (state.isLoading && state.sentLetters.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.sentLetters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send,
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Sent Letters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Write your first letter!',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(lettersProvider.notifier).loadLetters();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.sentLetters.length,
        itemBuilder: (context, index) {
          final letter = state.sentLetters[index];
          return _LetterCard(
            letter: letter,
            isReceived: false,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LetterDetailScreen(letter: letter),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  final Letter letter;
  final bool isReceived;
  final VoidCallback onTap;

  const _LetterCard({
    required this.letter,
    required this.isReceived,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final otherUser = isReceived ? letter.sender : letter.recipient;
    final canOpen = letter.canBeOpened;
    final isUnread = isReceived && !letter.isOpened && canOpen;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnread ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Envelope icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUnread
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      letter.isOpened
                          ? Icons.mail_outline
                          : Icons.mail,
                      color: isUnread
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Letter info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                letter.subject,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${isReceived ? 'From' : 'To'}: ${otherUser?.username ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.yMMMd().add_jm().format(letter.sentAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Status indicator
              if (isReceived) ...[
                const SizedBox(height: 12),
                _LetterStatusBanner(letter: letter),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LetterStatusBanner extends StatefulWidget {
  final Letter letter;

  const _LetterStatusBanner({required this.letter});

  @override
  State<_LetterStatusBanner> createState() => _LetterStatusBannerState();
}

class _LetterStatusBannerState extends State<_LetterStatusBanner> {
  @override
  void initState() {
    super.initState();
    if (!widget.letter.canBeOpened) {
      // Update every minute to show countdown
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
            Icon(Icons.lock_open, size: 16, color: colorScheme.onPrimaryContainer),
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
          Icon(Icons.lock_clock, size: 16, color: colorScheme.onSecondaryContainer),
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