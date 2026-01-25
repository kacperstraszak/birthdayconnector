import 'package:birthday_connector/models/birthday_twin.dart';
import 'package:birthday_connector/providers/profile_provider.dart';
import 'package:birthday_connector/providers/search_twin_provider.dart';
import 'package:birthday_connector/screens/write_letter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BirthdayTwinsScreen extends ConsumerStatefulWidget {
  const BirthdayTwinsScreen({super.key});

  @override
  ConsumerState<BirthdayTwinsScreen> createState() =>
      _BirthdayTwinsScreenState();
}

class _BirthdayTwinsScreenState extends ConsumerState<BirthdayTwinsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTwins();
    });
  }

  Future<void> _loadTwins() async {
    final profile = ref.read(profileProvider).profile;
    if (profile != null) {
      await ref
          .read(birthdayTwinsProvider.notifier)
          .loadMyBirthdayTwins(profile.birthDate);

      final state = ref.read(birthdayTwinsProvider);
      if (state.errorMessage != null) {
        print('RPC failed, trying direct query...');
        await ref
            .read(birthdayTwinsProvider.notifier)
            .loadMyBirthdayTwinsDirectQuery(profile.birthDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final twinsState = ref.watch(birthdayTwinsProvider);
    final profileState = ref.watch(profileProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final myBirthDate = profileState.profile?.birthDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Birthday Twins'),
      ),
      body: Column(
        children: [
          if (myBirthDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cake,
                    size: 48,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Birthday',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd().format(myBirthDate),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${twinsState.twins.length} Birthday Twin${twinsState.twins.length != 1 ? 's' : ''} Found',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: _buildTwinsList(twinsState, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildTwinsList(
      BirthdayTwinsState twinsState, ColorScheme colorScheme) {
    if (twinsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (twinsState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                twinsState.errorMessage!,
                style: TextStyle(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadTwins,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (twinsState.twins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Birthday Twins Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'You don\'t have any birthday twins registered yet. Check back later!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTwins,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: twinsState.twins.length,
        itemBuilder: (context, index) {
          final twin = twinsState.twins[index];
          return _BirthdayTwinCard(
            twin: twin,
            onWriteLetter: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WriteLetterScreen(
                    recipient: twin.toUserProfile(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BirthdayTwinCard extends StatelessWidget {
  final BirthdayTwin twin;
  final VoidCallback onWriteLetter;

  const _BirthdayTwinCard({
    required this.twin,
    required this.onWriteLetter,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final age = twin.age;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    twin.username.isNotEmpty
                        ? twin.username[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        twin.username,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.cake,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Same birthday! ($age years old)',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (twin.bio != null && twin.bio!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                twin.bio!,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (twin.interests != null && twin.interests!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: twin.interests!.split(',').map((interest) {
                  return Chip(
                    label: Text(
                      interest.trim(),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    backgroundColor: colorScheme.secondaryContainer,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
            if (twin.iceBreakerQuestion != null &&
                twin.iceBreakerQuestion!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        twin.iceBreakerQuestion!,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onWriteLetter,
                icon: const Icon(Icons.mail_outline),
                label: const Text('Write a Letter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
