import 'package:birthday_connector/providers/auth_provider.dart';
import 'package:birthday_connector/providers/home_data_provider.dart'; 
import 'package:birthday_connector/providers/profile_provider.dart';
import 'package:birthday_connector/screens/home_page.dart';
import 'package:birthday_connector/screens/messages_page.dart';
import 'package:birthday_connector/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticatedHomeScreen extends ConsumerStatefulWidget {
  const AuthenticatedHomeScreen({super.key});

  @override
  ConsumerState<AuthenticatedHomeScreen> createState() =>
      _AuthenticatedHomeScreenState();
}

class _AuthenticatedHomeScreenState
    extends ConsumerState<AuthenticatedHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      
      if (userId != null) {
        ref.read(profileProvider.notifier).loadProfile(userId);
        
        final userDate = authState.profile?.birthDate ?? DateTime.now();
        ref.read(homeDataProvider.notifier).loadDataForDate(userDate);
      }
    });
  }

  void _showLogoutDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        alignment: Alignment.center,
        icon: Icon(
          Icons.logout_rounded,
          color: colorScheme.error,
          size: 32,
        ),
        title: Text(
          'Logout',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to logout?',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authProvider.notifier).signOut();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomePage(),
      MessagesPage(),
      ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.mail_outline),
            selectedIcon: Icon(Icons.mail),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Messages';
      case 2:
        return 'Profile';
      default:
        return 'Birthday Connector';
    }
  }
}