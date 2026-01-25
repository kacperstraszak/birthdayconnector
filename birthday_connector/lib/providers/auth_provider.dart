import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:birthday_connector/models/user_profile.dart';
import 'package:birthday_connector/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  const AuthState({
    this.user,
    this.profile,
    this.isAuthenticating = false,
    this.errorMessage,
  });

  final User? user;
  final UserProfile? profile;
  final bool isAuthenticating;
  final String? errorMessage;

  AuthState copyWith({
    User? user,
    UserProfile? profile,
    bool? isAuthenticating,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final StreamSubscription _authSub;

  @override
  AuthState build() {
    final currentUser = supabase.auth.currentUser;

    if (currentUser != null) {
      Future.microtask(() => _loadProfile(currentUser.id));
    }

    _authSub = supabase.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      final user = session?.user;

      if (user != null) {
        state = state.copyWith(user: user);
        _loadProfile(user.id);
      } else {
        state = const AuthState(user: null);
      }
    });

    return AuthState(user: currentUser);
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final data = await supabase
          .from(kProfilesTable)
          .select()
          .eq(kUserIdCol, userId)
          .single();

      if (data[kBirthDateCol] is String) {
        data[kBirthDateCol] = DateTime.parse(data[kBirthDateCol] as String);
      }

      final profile = UserProfile.fromJson(data);

      state = state.copyWith(profile: profile);
    } on PostgrestException catch (e) {
      state =
          state.copyWith(errorMessage: 'Failed to load profile: ${e.message}');
    } catch (e) {
      state =
          state.copyWith(errorMessage: 'Unexpected error loading profile: $e');
    }
  }

  Future<void> _checkUsernameAvailability(String username) async {
    final existing = await supabase
        .from(kProfilesTable)
        .select('username')
        .eq(kUsernameCol, username)
        .maybeSingle();

    if (existing != null) {
      throw const AuthException('Username is already taken');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(
      isAuthenticating: true,
      errorMessage: null,
    );

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isAuthenticating: false,
        user: response.user,
      );

      if (response.user != null) {
        await _loadProfile(response.user!.id);
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        isAuthenticating: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isAuthenticating: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required DateTime birthDate,
  }) async {
    state = state.copyWith(
      isAuthenticating: true,
      errorMessage: null,
    );

    try {
      await _checkUsernameAvailability(username);

      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        throw const AuthException('Registration failed: User is null');
      }

      final formattedDate = DateTime(
        birthDate.year,
        birthDate.month,
        birthDate.day,
      );

      await supabase.from(kProfilesTable).insert({
        kUserIdCol: user.id,
        kUsernameCol: username.trim(),
        kEmailCol: email,
        kBirthDateCol:
            formattedDate.toIso8601String().split('T')[0], // Format: YYYY-MM-DD
      });

      state = state.copyWith(
        isAuthenticating: false,
        user: user,
      );

      await _loadProfile(user.id);
    } on AuthException catch (e) {
      state = state.copyWith(
        isAuthenticating: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isAuthenticating: false,
        errorMessage: 'An error occurred: $e',
      );
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    state = const AuthState(user: null);
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
