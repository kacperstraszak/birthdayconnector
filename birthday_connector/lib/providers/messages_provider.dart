import 'package:birthday_connector/models/letter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LettersState {
  final List<Letter> receivedLetters;
  final List<Letter> sentLetters;
  final bool isLoading;
  final String? errorMessage;

  LettersState({
    this.receivedLetters = const [],
    this.sentLetters = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  LettersState copyWith({
    List<Letter>? receivedLetters,
    List<Letter>? sentLetters,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LettersState(
      receivedLetters: receivedLetters ?? this.receivedLetters,
      sentLetters: sentLetters ?? this.sentLetters,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class LettersNotifier extends Notifier<LettersState> {
  SupabaseClient get _supabase => Supabase.instance.client;
  RealtimeChannel? _lettersSubscription;

  @override
  LettersState build() {
    _setupRealtimeSubscription();
    return LettersState();
  }

  void _setupRealtimeSubscription() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _lettersSubscription = _supabase
        .channel('letters_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'letters',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_id',
            value: userId,
          ),
          callback: (payload) {
            _handleNewLetter(payload.newRecord);
          },
        )
        .subscribe();
  }

  void _handleNewLetter(Map<String, dynamic> record) {
    final letter = Letter.fromJson(record);
    final updatedReceived = [...state.receivedLetters, letter];
    updatedReceived.sort((a, b) => b.sentAt.compareTo(a.sentAt));

    state = state.copyWith(receivedLetters: updatedReceived);
  }

  Future<void> loadLetters() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Load received letters
      final receivedResponse = await _supabase
          .from('letters')
          .select('''
            *,
            sender:user_profiles!letters_sender_id_fkey(*)
          ''')
          .eq('recipient_id', userId)
          .order('sent_at', ascending: false);

      final receivedLetters = (receivedResponse as List)
          .map((json) => Letter.fromJson(json))
          .toList();

      // Load sent letters
      final sentResponse = await _supabase
          .from('letters')
          .select('''
            *,
            recipient:user_profiles!letters_recipient_id_fkey(*)
          ''')
          .eq('sender_id', userId)
          .order('sent_at', ascending: false);

      final sentLetters = (sentResponse as List)
          .map((json) => Letter.fromJson(json))
          .toList();

      state = state.copyWith(
        receivedLetters: receivedLetters,
        sentLetters: sentLetters,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load letters: ${e.toString()}',
      );
    }
  }

  Future<bool> sendLetter({
    required String recipientId,
    required String subject,
    required String content,
    int deliveryDelayHours = 12,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final sentAt = DateTime.now();
      final canOpenAt = sentAt.add(Duration(hours: deliveryDelayHours));

      await _supabase.from('letters').insert({
        'sender_id': userId,
        'recipient_id': recipientId,
        'subject': subject,
        'content': content,
        'sent_at': sentAt.toIso8601String(),
        'can_open_at': canOpenAt.toIso8601String(),
      });

      await loadLetters();
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to send letter: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> openLetter(String letterId) async {
    try {
      await _supabase
          .from('letters')
          .update({
            'is_opened': true,
            'opened_at': DateTime.now().toIso8601String(),
          })
          .eq('id', letterId);

      // Update local state
      final updatedReceived = state.receivedLetters.map((letter) {
        if (letter.id == letterId) {
          return Letter(
            id: letter.id,
            senderId: letter.senderId,
            recipientId: letter.recipientId,
            subject: letter.subject,
            content: letter.content,
            sentAt: letter.sentAt,
            canOpenAt: letter.canOpenAt,
            isOpened: true,
            openedAt: DateTime.now(),
            sender: letter.sender,
            recipient: letter.recipient,
          );
        }
        return letter;
      }).toList();

      state = state.copyWith(receivedLetters: updatedReceived);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to open letter: ${e.toString()}',
      );
      return false;
    }
  }


}

final lettersProvider = NotifierProvider<LettersNotifier, LettersState>(() {
  return LettersNotifier();
});