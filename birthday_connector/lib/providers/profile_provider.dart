import 'package:birthday_connector/models/birthday_twin.dart';
import 'package:birthday_connector/models/user_profile.dart';
import 'package:birthday_connector/utils/constants.dart';
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
    bool clearError = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      birthdayTwins: birthdayTwins ?? this.birthdayTwins,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _supabase
          .from(kProfilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle(); 

      if (response == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

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
    required String email,
    required DateTime birthDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _supabase.from(kProfilesTable).insert({
        'id': userId,
        'username': username,
        'email': email,
        'birth_date': birthDate.toIso8601String().split('T')[0],
      });

      await loadProfile(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create profile: ${e.toString()}',
      );
    }
  }

  Future<void> updateProfile({
    String? bio,
    String? interests,
    String? iceBreakerQuestion,
  }) async {
    if (state.profile == null) {
      state = state.copyWith(
        errorMessage: 'Profile not loaded. Please try again.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updates = <String, dynamic>{};

      updates['bio'] = bio?.trim().isEmpty ?? true ? null : bio!.trim();
      updates['interests'] = interests?.trim().isEmpty ?? true ? null : interests!.trim();
      updates['ice_breaker_question'] = 
          iceBreakerQuestion?.trim().isEmpty ?? true ? null : iceBreakerQuestion!.trim();


      final response = await _supabase
          .from(kProfilesTable)
          .update(updates)
          .eq('id', state.profile!.id)
          .select()
          .single();


      final updatedProfile = UserProfile.fromJson(response);
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

      if (response == null) {
        state = state.copyWith(birthdayTwins: []);
        return;
      }

      final twins = (response as List)
          .map((json) => BirthdayTwin.fromJson(json))
          .toList();

      state = state.copyWith(birthdayTwins: twins);
    } catch (e) {
    }
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});