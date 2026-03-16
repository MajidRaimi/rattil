import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'wird_provider.g.dart';

class WirdConfig {
  final int pageCount;
  final int currentStartPage;
  final int? reminderHour;
  final int? reminderMinute;

  const WirdConfig({
    required this.pageCount,
    required this.currentStartPage,
    this.reminderHour,
    this.reminderMinute,
  });

  int get endPage => min(currentStartPage + pageCount - 1, 604);
  bool get hasReminder => reminderHour != null;
}

const _kPageCount = 'wird_page_count';
const _kCurrentStart = 'wird_current_start';
const _kReminderHour = 'wird_reminder_hour';
const _kReminderMinute = 'wird_reminder_minute';
const _kLastCompletedDate = 'wird_last_completed_date';

@Riverpod(keepAlive: true)
class WirdConfigNotifier extends _$WirdConfigNotifier {
  @override
  WirdConfig? build() {
    _loadFromPrefs();
    return null;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final pageCount = prefs.getInt(_kPageCount);
    if (pageCount == null) return;

    var currentStart = prefs.getInt(_kCurrentStart) ?? 1;

    // Auto-advance: if last completion was before today, advance
    final lastCompleted = prefs.getString(_kLastCompletedDate);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastCompleted != null && lastCompleted != today) {
      final end = min(currentStart + pageCount - 1, 604);
      currentStart = end >= 604 ? 1 : end + 1;
      await prefs.setInt(_kCurrentStart, currentStart);
      await prefs.remove(_kLastCompletedDate);
    }

    state = WirdConfig(
      pageCount: pageCount,
      currentStartPage: currentStart,
      reminderHour: prefs.getInt(_kReminderHour),
      reminderMinute: prefs.getInt(_kReminderMinute),
    );
  }

  Future<void> setWird(int pageCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPageCount, pageCount);
    await prefs.setInt(_kCurrentStart, 1);
    await prefs.remove(_kLastCompletedDate);
    state = WirdConfig(
      pageCount: pageCount,
      currentStartPage: 1,
      reminderHour: state?.reminderHour,
      reminderMinute: state?.reminderMinute,
    );
  }

  Future<void> editWird(int startPage, int pageCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPageCount, pageCount);
    await prefs.setInt(_kCurrentStart, startPage);
    state = WirdConfig(
      pageCount: pageCount,
      currentStartPage: startPage,
      reminderHour: state?.reminderHour,
      reminderMinute: state?.reminderMinute,
    );
  }

  /// Called when today's wird is marked complete.
  Future<void> onWirdCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_kLastCompletedDate, today);
  }

  /// Called when today's wird completion is reverted.
  Future<void> onWirdUncompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastCompletedDate);
  }

  Future<void> clearWird() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPageCount);
    await prefs.remove(_kCurrentStart);
    await prefs.remove(_kReminderHour);
    await prefs.remove(_kReminderMinute);
    await prefs.remove(_kLastCompletedDate);
    state = null;
  }

  Future<void> setReminder(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kReminderHour, hour);
    await prefs.setInt(_kReminderMinute, minute);
    if (state != null) {
      state = WirdConfig(
        pageCount: state!.pageCount,
        currentStartPage: state!.currentStartPage,
        reminderHour: hour,
        reminderMinute: minute,
      );
    }
  }

  Future<void> clearReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kReminderHour);
    await prefs.remove(_kReminderMinute);
    if (state != null) {
      state = WirdConfig(
        pageCount: state!.pageCount,
        currentStartPage: state!.currentStartPage,
      );
    }
  }
}
