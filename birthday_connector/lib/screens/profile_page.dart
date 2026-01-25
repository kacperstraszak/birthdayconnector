import 'package:birthday_connector/models/birthday_twin.dart';
import 'package:birthday_connector/providers/auth_provider.dart';
import 'package:birthday_connector/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _bioController = TextEditingController();
  final _interestsController = TextEditingController();
  final _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authProvider).user?.id;
      if (userId != null) {
        ref.read(profileProvider.notifier).loadProfile(userId);
      }
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    _interestsController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final notifier = ref.read(profileProvider.notifier);
    await notifier.updateProfile(
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      interests: _interestsController.text.trim().isEmpty
          ? null
          : _interestsController.text.trim(),
      iceBreakerQuestion: _questionController.text.trim().isEmpty
          ? null
          : _questionController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);

    // Update controllers when profile loads
    ref.listen<ProfileState>(profileProvider, (previous, next) {
      if (next.profile != null && previous?.profile == null) {
        _bioController.text = next.profile!.bio ?? '';
        _interestsController.text = next.profile!.interests ?? '';
        _questionController.text = next.profile!.iceBreakerQuestion ?? '';
      }
    });

    if (profileState.isLoading && profileState.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = profileState.profile;
    final username = profile?.username ??
        authState.user?.userMetadata?['username'] ??
        'User';

    final birthDate = profile?.birthDate ??
        (authState.user?.userMetadata?['birth_date'] != null
            ? DateTime.parse(authState.user!.userMetadata!['birth_date'])
            : DateTime.now());

    return RefreshIndicator(
      onRefresh: () async {
        final userId = authState.user?.id;
        if (userId != null) {
          await ref.read(profileProvider.notifier).loadProfile(userId);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          username[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        username,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cake_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Born: ${birthDate.day}.${birthDate.month}.${birthDate.year}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Edit Profile Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Edit Profile',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'About Me',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        controller: _bioController,
                        maxLines: 3,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          hintText: 'Tell others about yourself...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Interests',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _interestsController,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLength: 100,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Music, Sports, Reading...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ice Breaker Question',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ask a question for birthday twins to answer when messaging you',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        controller: _questionController,
                        maxLines: 2,
                        maxLength: 150,
                        decoration: const InputDecoration(
                          hintText:
                              'e.g., What\'s your favorite childhood memory?',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: profileState.isLoading ? null : _saveProfile,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: profileState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Profile'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
