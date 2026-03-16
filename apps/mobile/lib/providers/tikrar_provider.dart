import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TikrarSession {
  final String id;
  final int surahNumber;
  final String surahNameArabic;
  final String surahNameEnglish;
  final int startVerse;
  final int endVerse;
  int repetitions;
  String reciterId;
  int currentStepIndex;
  int currentRepetition;
  int currentVerseInStep;
  final DateTime createdAt;

  TikrarSession({
    required this.id,
    required this.surahNumber,
    required this.surahNameArabic,
    required this.surahNameEnglish,
    required this.startVerse,
    required this.endVerse,
    required this.repetitions,
    required this.reciterId,
    this.currentStepIndex = 0,
    this.currentRepetition = 1,
    this.currentVerseInStep = 0,
    required this.createdAt,
  });

  int get totalSteps {
    final n = endVerse - startVerse + 1;
    return n <= 1 ? 1 : 2 * n - 1;
  }

  double get progress => totalSteps > 0 ? currentStepIndex / totalSteps : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'surahNumber': surahNumber,
        'surahNameArabic': surahNameArabic,
        'surahNameEnglish': surahNameEnglish,
        'startVerse': startVerse,
        'endVerse': endVerse,
        'repetitions': repetitions,
        'reciterId': reciterId,
        'currentStepIndex': currentStepIndex,
        'currentRepetition': currentRepetition,
        'currentVerseInStep': currentVerseInStep,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TikrarSession.fromJson(Map<String, dynamic> json) => TikrarSession(
        id: json['id'] as String,
        surahNumber: json['surahNumber'] as int,
        surahNameArabic: json['surahNameArabic'] as String,
        surahNameEnglish: json['surahNameEnglish'] as String,
        startVerse: json['startVerse'] as int,
        endVerse: json['endVerse'] as int,
        repetitions: json['repetitions'] as int,
        reciterId: json['reciterId'] as String,
        currentStepIndex: json['currentStepIndex'] as int? ?? 0,
        currentRepetition: json['currentRepetition'] as int? ?? 1,
        currentVerseInStep: json['currentVerseInStep'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

const _kTikrarSessions = 'tikrar_sessions';

class TikrarSessionsNotifier extends Notifier<List<TikrarSession>> {
  @override
  List<TikrarSession> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kTikrarSessions);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => TikrarSession.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {
      // Corrupted data — reset
      await prefs.remove(_kTikrarSessions);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kTikrarSessions,
      jsonEncode(state.map((s) => s.toJson()).toList()),
    );
  }

  Future<TikrarSession> createSession({
    required int surahNumber,
    required String surahNameArabic,
    required String surahNameEnglish,
    required int startVerse,
    required int endVerse,
    required int repetitions,
    required String reciterId,
  }) async {
    final session = TikrarSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      surahNumber: surahNumber,
      surahNameArabic: surahNameArabic,
      surahNameEnglish: surahNameEnglish,
      startVerse: startVerse,
      endVerse: endVerse,
      repetitions: repetitions,
      reciterId: reciterId,
      createdAt: DateTime.now(),
    );
    state = [...state, session];
    await _save();
    return session;
  }

  Future<void> updateSession(TikrarSession session) async {
    state = [
      for (final s in state)
        if (s.id == session.id) session else s,
    ];
    await _save();
  }

  Future<void> deleteSession(String id) async {
    state = state.where((s) => s.id != id).toList();
    await _save();
  }
}

final tikrarSessionsProvider =
    NotifierProvider<TikrarSessionsNotifier, List<TikrarSession>>(
  TikrarSessionsNotifier.new,
);
