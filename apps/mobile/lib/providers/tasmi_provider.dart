import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasmiSession {
  final String id;
  final int surahNumber;
  final String surahNameArabic;
  final String surahNameEnglish;
  final int startVerse;
  final int endVerse;
  int currentVerse;
  int correctVerses;
  final DateTime createdAt;

  TasmiSession({
    required this.id,
    required this.surahNumber,
    required this.surahNameArabic,
    required this.surahNameEnglish,
    required this.startVerse,
    required this.endVerse,
    this.currentVerse = 0,
    this.correctVerses = 0,
    required this.createdAt,
  });

  int get totalVerses => endVerse - startVerse + 1;
  double get progress => totalVerses > 0 ? correctVerses / totalVerses : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'surahNumber': surahNumber,
        'surahNameArabic': surahNameArabic,
        'surahNameEnglish': surahNameEnglish,
        'startVerse': startVerse,
        'endVerse': endVerse,
        'currentVerse': currentVerse,
        'correctVerses': correctVerses,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TasmiSession.fromJson(Map<String, dynamic> json) => TasmiSession(
        id: json['id'] as String,
        surahNumber: json['surahNumber'] as int,
        surahNameArabic: json['surahNameArabic'] as String,
        surahNameEnglish: json['surahNameEnglish'] as String,
        startVerse: json['startVerse'] as int,
        endVerse: json['endVerse'] as int,
        currentVerse: json['currentVerse'] as int? ?? 0,
        correctVerses: json['correctVerses'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

const _kTasmiSessions = 'tasmi_sessions';

class TasmiSessionsNotifier extends Notifier<List<TasmiSession>> {
  @override
  List<TasmiSession> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kTasmiSessions);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => TasmiSession.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {
      await prefs.remove(_kTasmiSessions);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kTasmiSessions,
      jsonEncode(state.map((s) => s.toJson()).toList()),
    );
  }

  Future<TasmiSession> createSession({
    required int surahNumber,
    required String surahNameArabic,
    required String surahNameEnglish,
    required int startVerse,
    required int endVerse,
  }) async {
    final session = TasmiSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      surahNumber: surahNumber,
      surahNameArabic: surahNameArabic,
      surahNameEnglish: surahNameEnglish,
      startVerse: startVerse,
      endVerse: endVerse,
      createdAt: DateTime.now(),
    );
    state = [...state, session];
    await _save();
    return session;
  }

  Future<void> updateSession(TasmiSession session) async {
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

final tasmiSessionsProvider =
    NotifierProvider<TasmiSessionsNotifier, List<TasmiSession>>(
  TasmiSessionsNotifier.new,
);
