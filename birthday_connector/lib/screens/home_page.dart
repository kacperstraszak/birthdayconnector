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
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);
    final homeDataState = ref.watch(homeDataProvider);
    final colorScheme = Theme.of(context).colorScheme; 

    final birthDate = profileState.profile?.birthDate;

    if (profileState.isLoading && profileState.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              profileState.errorMessage!,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final userId = authState.user?.id;
                if (userId != null) {
                  ref.read(profileProvider.notifier).loadProfile(userId);
                }
              },
              child: Text(
                'Retry',
                style: TextStyle(color: colorScheme.primary), 
              ),
            ),
          ],
        ),
      );
    }

    if (birthDate == null) {
      return Center(
        child: Text(
          'No profile data available',
          style: TextStyle(color: colorScheme.onSurface),
        ),
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
              HistoricalEventCard(events: homeDataState.historicalEvents),
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
                color: colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          homeDataState.errorMessage!,
                          style: TextStyle(
                            color: colorScheme.onErrorContainer,
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, 
              ),
        ),
      ],
    );
  }
}