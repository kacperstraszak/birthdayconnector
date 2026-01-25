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

  HomeDataState({
    this.famousBirthdays = const [],
    this.historicalEvents = const [],
    this.countdownEvents = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HomeDataState copyWith({
    List<FamousBirthday>? famousBirthdays,
    List<HistoricalEvent>? historicalEvents,
    List<CountdownEvent>? countdownEvents,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeDataState(
      famousBirthdays: famousBirthdays ?? this.famousBirthdays,
      historicalEvents: historicalEvents ?? this.historicalEvents,
      countdownEvents: countdownEvents ?? this.countdownEvents,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
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
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final month = date.month;
      final day = date.day;

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

        birthdays = (birthdaysResponse as List)
            .map((json) => FamousBirthday.fromJson(json))
            .toList();
      } catch (e) {
        print('Error loading birthdays: $e');
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

        events = (eventsResponse as List)
            .map((json) => HistoricalEvent.fromJson(json))
            .toList();
      } catch (e) {
        print('Error loading events: $e');
      }

      List<CountdownEvent> countdowns = [];
      try {
        final countdownResponse = await _supabase
            .from('countdown_events')
            .select()
            .gte('event_date', DateTime.now().toIso8601String())
            .order('event_date', ascending: true)
            .limit(3);

        countdowns = (countdownResponse as List)
            .map((json) => CountdownEvent.fromJson(json))
            .toList();
      } catch (e) {
        print('Error loading countdowns: $e');
      }

      state = state.copyWith(
        famousBirthdays: birthdays,
        historicalEvents: events,
        countdownEvents: countdowns,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load data: $e',
      );
    }
  }
}


final homeDataProvider =
    NotifierProvider<HomeDataNotifier, HomeDataState>(
  HomeDataNotifier.new,
);
