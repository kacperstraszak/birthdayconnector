import 'package:birthday_connector/providers/auth_provider.dart';
import 'package:birthday_connector/screens/auth.dart';
import 'package:birthday_connector/screens/authenticated_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user != null) {
      return const AuthenticatedHomeScreen();
    }

    return const AuthScreen();
  }
}
