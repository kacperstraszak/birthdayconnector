import 'package:birthday_connector/models/countdown_event.dart';
import 'package:birthday_connector/models/famous_birthday.dart';
import 'package:birthday_connector/models/historical_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeDataState {
  final List<FamousBirthday> famousBirthdays;
  final List<HistoricalEvent> historicalEvents;
  final List<CountdownEvent> countdownEvents;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? loadedForDate;

  HomeDataState({
    this.famousBirthdays = const [],
    this.historicalEvents = const [],
    this.countdownEvents = const [],
    this.isLoading = false,
    this.errorMessage,
    this.loadedForDate,
  });

  HomeDataState copyWith({
    List<FamousBirthday>? famousBirthdays,
    List<HistoricalEvent>? historicalEvents,
    List<CountdownEvent>? countdownEvents,
    bool? isLoading,
    String? errorMessage,
    DateTime? loadedForDate,
    bool clearError = false,
  }) {
    return HomeDataState(
      famousBirthdays: famousBirthdays ?? this.famousBirthdays,
      historicalEvents: historicalEvents ?? this.historicalEvents,
      countdownEvents: countdownEvents ?? this.countdownEvents,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loadedForDate: loadedForDate ?? this.loadedForDate,
    );
  }
}

class HomeDataNotifier extends Notifier<HomeDataState> {
  late final SupabaseClient _supabase;

  @override
  HomeDataState build() {
    _supabase = Supabase.instance.client;
    return HomeDataState();
  }

  Future<void> loadDataForDate(DateTime date, {int limit = 5}) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (state.loadedForDate != null) {
      final loadedDate = DateTime(
        state.loadedForDate!.year,
        state.loadedForDate!.month,
        state.loadedForDate!.day,
      );
      if (loadedDate == normalizedDate && !state.isLoading) {
        return;
      }
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final month = normalizedDate.month;
      final day = normalizedDate.day;

      List<FamousBirthday> birthdays = [];
      try {
        final birthdaysResponse = await _supabase.rpc(
          'get_famous_birthdays_for_date',
          params: {
            'p_month': month,
            'p_day': day,
            'p_limit': limit,
          },
        );

        if (birthdaysResponse != null && birthdaysResponse is List) {
          birthdays = (birthdaysResponse as List)
              .map((json) {
                try {
                  return FamousBirthday.fromJson(json);
                } catch (e) {
                  return null;
                }
              })
              .whereType<FamousBirthday>()
              .toList();
        }
      } catch (e) {
        // Ignore error
      }

      List<HistoricalEvent> events = [];
      try {
        final eventsResponse = await _supabase.rpc(
          'get_historical_events_for_date',
          params: {
            'p_month': month,
            'p_day': day,
            'p_limit': limit,
          },
        );

        if (eventsResponse != null && eventsResponse is List) {
          events = (eventsResponse as List)
              .map((json) {
                try {
                  return HistoricalEvent.fromJson(json);
                } catch (e) {
                  return null;
                }
              })
              .whereType<HistoricalEvent>()
              .toList();
        }
      } catch (e) {
        // Ignore error
      }

      List<CountdownEvent> countdowns = [];
      try {
        final countdownResponse = await _supabase
            .from('countdown_events')
            .select()
            .gte('event_date', DateTime.now().toIso8601String())
            .order('event_date', ascending: true)
            .limit(limit);

        if (countdownResponse != null && countdownResponse is List) {
          countdowns = (countdownResponse as List)
              .map((json) {
                try {
                  return CountdownEvent.fromJson(json);
                } catch (e) {
                  return null;
                }
              })
              .whereType<CountdownEvent>()
              .toList();
        }
      } catch (e) {
        // Ignore error
      }

      state = state.copyWith(
        famousBirthdays: birthdays,
        historicalEvents: events,
        countdownEvents: countdowns,
        isLoading: false,
        loadedForDate: normalizedDate,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load data: $e',
      );
    }
  }

  Future<void> forceReload(DateTime date, {int limit = 5}) async {
    state = state.copyWith(loadedForDate: null);
    await loadDataForDate(date, limit: limit);
  }

  void clearData() {
    state = HomeDataState();
  }
}

final homeDataProvider = NotifierProvider<HomeDataNotifier, HomeDataState>(
  HomeDataNotifier.new,
);
