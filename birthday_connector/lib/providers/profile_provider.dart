import 'package:birthday_connector/models/birthday_twin.dart';
import 'package:birthday_connector/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileState {
  final UserProfile? profile;
  final List<BirthdayTwin> birthdayTwins;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({
    this.profile,
    this.birthdayTwins = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserProfile? profile,
    List<BirthdayTwin>? birthdayTwins,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      birthdayTwins: birthdayTwins ?? this.birthdayTwins,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  ProfileState build() {
    return ProfileState();
  }

  Future<void> loadProfile(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = UserProfile.fromJson(response);
      state = state.copyWith(profile: profile, isLoading: false);

      await loadBirthdayTwins(profile.birthDate);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile: ${e.toString()}',
      );
    }
  }

  Future<void> createProfile({
    required String userId,
    required String username,
    required DateTime birthDate,
  }) async {
    try {
      await _supabase.from('user_profiles').insert({
        'id': userId,
        'username': username,
        'birth_date': birthDate.toIso8601String().split('T')[0],
      });

      await loadProfile(userId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to create profile: ${e.toString()}',
      );
    }
  }

  Future<void> updateProfile({
    String? bio,
    String? interests,
    String? iceBreakerQuestion,
  }) async {
    if (state.profile == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _supabase.from('user_profiles').update({
        if (bio != null) 'bio': bio,
        if (interests != null) 'interests': interests,
        if (iceBreakerQuestion != null)
          'ice_breaker_question': iceBreakerQuestion,
      }).eq('id', state.profile!.id);

      final updatedProfile = state.profile!.copyWith(
        bio: bio,
        interests: interests,
        iceBreakerQuestion: iceBreakerQuestion,
      );

      state = state.copyWith(profile: updatedProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update profile: ${e.toString()}',
      );
    }
  }

  Future<void> loadBirthdayTwins(DateTime birthDate) async {
    try {
      final response = await _supabase.rpc('get_birthday_twins', params: {
        'user_birth_date': birthDate.toIso8601String().split('T')[0],
        'limit_count': 5,
      });

      final twins = (response as List)
          .map((json) => BirthdayTwin.fromJson(json))
          .toList();

      state = state.copyWith(birthdayTwins: twins);
    } catch (e) {
      print('Failed to load birthday twins: ${e.toString()}');
    }
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});