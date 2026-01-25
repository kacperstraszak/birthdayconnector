import 'package:birthday_connector/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BirthdayTwinsState {
  final List<UserProfile> twins;
  final bool isLoading;
  final String? errorMessage;

  BirthdayTwinsState({
    this.twins = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BirthdayTwinsState copyWith({
    List<UserProfile>? twins,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BirthdayTwinsState(
      twins: twins ?? this.twins,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class BirthdayTwinsNotifier extends Notifier<BirthdayTwinsState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  BirthdayTwinsState build() {
    return BirthdayTwinsState();
  }

  Future<void> loadMyBirthdayTwins(DateTime myBirthDate) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('birth_date', myBirthDate.toIso8601String().split('T')[0])
          .neq('id', currentUserId ?? '')
          .order('username');

      final twins = (response as List)
          .map((json) => UserProfile.fromJson(json))
          .toList();

      state = state.copyWith(
        twins: twins,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load birthday twins: ${e.toString()}',
      );
    }
  }

  void clearTwins() {
    state = BirthdayTwinsState();
  }
}

final birthdayTwinsProvider = NotifierProvider<BirthdayTwinsNotifier, BirthdayTwinsState>(() {
  return BirthdayTwinsNotifier();
});