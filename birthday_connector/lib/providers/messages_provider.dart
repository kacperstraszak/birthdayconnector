import 'package:birthday_connector/models/letter.dart';
import 'package:birthday_connector/utils/constants.dart';
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

  @override
  LettersState build() {
    return LettersState();
  }

  Future<void> loadLetters() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final receivedResponse = await _supabase.from('letters').select('''
            *,
            sender:$kProfilesTable!letters_sender_id_fkey(*)
          ''').eq('recipient_id', userId).order('sent_at', ascending: false);

      final receivedLetters = (receivedResponse as List)
          .map((json) => Letter.fromJson(json))
          .toList();

      final sentResponse = await _supabase.from('letters').select('''
            *,
            recipient:$kProfilesTable!letters_recipient_id_fkey(*)
          ''').eq('sender_id', userId).order('sent_at', ascending: false);

      final sentLetters =
          (sentResponse as List).map((json) => Letter.fromJson(json)).toList();

      state = state.copyWith(
        receivedLetters: receivedLetters,
        sentLetters: sentLetters,
        isLoading: false,
      );
    } catch (e) {
      print('CRITICAL ERROR loading letters: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading letters: $e',
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
        errorMessage: 'Failed to send letter: $e',
      );
      return false;
    }
  }

  Future<bool> openLetter(String letterId) async {
    try {
      await _supabase.from('letters').update({
        'is_opened': true,
        'opened_at': DateTime.now().toIso8601String(),
      }).eq('id', letterId);

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
      print('Error opening letter: $e');
      return false;
    }
  }
}

final lettersProvider = NotifierProvider<LettersNotifier, LettersState>(() {
  return LettersNotifier();
});
