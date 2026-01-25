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
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  void _loadProfileData() {
    final userId = ref.read(authProvider).user?.id;
    if (userId != null) {
      ref.read(profileProvider.notifier).loadProfile(userId);
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _interestsController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _updateControllers(ProfileState state) {
    if (state.profile != null && !_hasLoadedData) {
      _bioController.text = state.profile!.bio ?? '';
      _interestsController.text = state.profile!.interests ?? '';
      _questionController.text = state.profile!.iceBreakerQuestion ?? '';
      _hasLoadedData = true;
    }
  }

  Future<void> _saveProfile() async {
    final notifier = ref.read(profileProvider.notifier);
    FocusScope.of(context).unfocus();
    
    print('Saving profile...');
    print('Bio: "${_bioController.text}"');
    print('Interests: "${_interestsController.text}"');
    print('Question: "${_questionController.text}"');
    
    await notifier.updateProfile(
      bio: _bioController.text,
      interests: _interestsController.text,
      iceBreakerQuestion: _questionController.text,
    );

    if (!mounted) return;

    final errorMessage = ref.read(profileProvider).errorMessage;
    if (errorMessage == null) {
      print('Profile saved successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated successfully!',
            style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        ),
      );
    } else {
      print('Error saving profile: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);

    _updateControllers(profileState);

    if (profileState.isLoading && profileState.profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = profileState.profile;
    final username = profile?.username ??
        authState.user?.userMetadata?['username'] ??
        'User';

    final birthDate = profile?.birthDate ??
        (authState.user?.userMetadata?['birth_date'] != null
            ? DateTime.tryParse(authState.user!.userMetadata!['birth_date'].toString()) ?? DateTime.now()
            : DateTime.now());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = authState.user?.id;
          if (userId != null) {
            _hasLoadedData = false; 
            await ref.read(profileProvider.notifier).loadProfile(userId);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            username.isNotEmpty ? username[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          username,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cake_outlined,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Born: ${birthDate.day}.${birthDate.month}.${birthDate.year}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
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
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      
                      Text(
                        'About Me',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _bioController,
                        maxLines: 3,
                        maxLength: 200,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Tell others about yourself...',
                          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Interests',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _interestsController,
                        maxLength: 100,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'e.g., Music, Sports, Reading...',
                          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Ice Breaker Question',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ask a question for birthday twins to answer when messaging you',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _questionController,
                        maxLines: 2,
                        maxLength: 150,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'e.g., What\'s your favorite childhood memory?',
                          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 24),

                      FilledButton.icon(
                        onPressed: profileState.isLoading ? null : _saveProfile,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        icon: profileState.isLoading 
                            ? const SizedBox.shrink() 
                            : const Icon(Icons.save),
                        label: profileState.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Text('Save Profile'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}