import 'package:birthday_connector/models/birthday_twin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BirthdayTwinsState {
  final List<BirthdayTwin> twins;
  final bool isLoading;
  final String? errorMessage;

  BirthdayTwinsState({
    this.twins = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BirthdayTwinsState copyWith({
    List<BirthdayTwin>? twins,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BirthdayTwinsState(
      twins: twins ?? this.twins,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class BirthdayTwinsNotifier extends Notifier<BirthdayTwinsState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  BirthdayTwinsState build() {
    return BirthdayTwinsState();
  }

  Future<void> loadMyBirthdayTwins(DateTime birthDate) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      final response = await _supabase.rpc(
        'get_my_birthday_twins',
        params: {'user_id': currentUserId},
      );
      if (response == null) {
        state = state.copyWith(twins: [], isLoading: false);
        return;
      }
      final twins = (response as List)
          .map((json) {
            try {
              return BirthdayTwin.fromJson(json);
            } catch (e) {
              return null;
            }
          })
          .whereType<BirthdayTwin>()
          .toList();

      state = state.copyWith(twins: twins, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load birthday twins: ${e.toString()}',
      );
    }
  }

  Future<void> loadMyBirthdayTwinsDirectQuery(DateTime birthDate) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final birthDateStr = birthDate.toIso8601String().split('T')[0];

      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('birth_date', birthDateStr)
          .neq('id', currentUserId)
          .order('username');

      final twins = (response as List)
          .map((json) => BirthdayTwin.fromJson(json))
          .toList();

      state = state.copyWith(twins: twins, isLoading: false);
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

final birthdayTwinsProvider =
    NotifierProvider<BirthdayTwinsNotifier, BirthdayTwinsState>(() {
  return BirthdayTwinsNotifier();
});
