import 'package:birthday_connector/providers/messages_provider.dart';
import 'package:birthday_connector/screens/birthday_twins.dart';
import 'package:birthday_connector/screens/letter_detail.dart';
import 'package:birthday_connector/widgets/letter_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    if (state.errorMessage != null && state.receivedLetters.isEmpty) {
      return _buildErrorView(state.errorMessage!, colorScheme);
    }

    if (state.receivedLetters.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(lettersProvider.notifier).loadLetters();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
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
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(lettersProvider.notifier).loadLetters();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check for new letters'),
                  ),
                ],
              ),
            ),
          ),
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
          return LetterCard(
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

    if (state.errorMessage != null && state.sentLetters.isEmpty) {
      return _buildErrorView(state.errorMessage!, colorScheme);
    }

    if (state.sentLetters.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(lettersProvider.notifier).loadLetters();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
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
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(lettersProvider.notifier).loadLetters();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          ),
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
          return LetterCard(
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

  Widget _buildErrorView(String message, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(lettersProvider.notifier).loadLetters();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(lettersProvider.notifier).loadLetters();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
