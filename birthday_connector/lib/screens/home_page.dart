import 'package:birthday_connector/providers/auth_provider.dart';
import 'package:birthday_connector/providers/home_data_provider.dart';
import 'package:birthday_connector/providers/profile_provider.dart';
import 'package:birthday_connector/widgets/countdown_card.dart';
import 'package:birthday_connector/widgets/famous_birthday_card.dart';
import 'package:birthday_connector/widgets/historical_event_card.dart';
import 'package:birthday_connector/widgets/life_statistics_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = ref.read(profileProvider);
      if (profileState.profile?.birthDate != null) {
        ref.read(homeDataProvider.notifier).loadDataForDate(
              profileState.profile!.birthDate,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);
    final homeDataState = ref.watch(homeDataProvider);

    final birthDate = profileState.profile?.birthDate;

    if (profileState.isLoading && profileState.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(profileState.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final userId = authState.user?.id;
                if (userId != null) {
                  ref.read(profileProvider.notifier).loadProfile(userId);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (birthDate == null) {
      return const Center(
        child: Text('No profile data available'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final userId = authState.user?.id;
        if (userId != null) {
          await ref.read(profileProvider.notifier).loadProfile(userId);
          await ref.read(homeDataProvider.notifier).loadDataForDate(birthDate);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LifeStatisticsCard(birthDate: birthDate),
            const SizedBox(height: 24),
            if (homeDataState.countdownEvents.isNotEmpty) ...[
              const _SectionHeader(
                title: 'Upcoming Events',
                icon: Icons.schedule,
              ),
              const SizedBox(height: 12),
              ...homeDataState.countdownEvents.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CountdownCard(event: event),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (homeDataState.famousBirthdays.isNotEmpty) ...[
              const _SectionHeader(
                title: 'Born on Your Birthday',
                icon: Icons.cake,
              ),
              const SizedBox(height: 12),
              ...homeDataState.famousBirthdays.map(
                (birthday) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FamousBirthdayCard(birthday: birthday),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (homeDataState.historicalEvents.isNotEmpty) ...[
              const _SectionHeader(
                title: 'Historical Events on Your Birthday',
                icon: Icons.history_edu,
              ),
              const SizedBox(height: 12),
              ...homeDataState.historicalEvents.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: HistoricalEventCard(event: event),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (homeDataState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
            if (homeDataState.errorMessage != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          homeDataState.errorMessage!,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
