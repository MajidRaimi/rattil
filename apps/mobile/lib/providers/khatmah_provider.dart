import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/analytics_service.dart';

part 'khatmah_provider.g.dart';

class KhatmahConfig {
  final int totalDays;
  final String startDate; // ISO8601 date string (yyyy-MM-dd)
  final int completedDays;
  final int? lastReadPage;
  final bool paused;
  final int? reminderHour;
  final int? reminderMinute;

  const KhatmahConfig({
    required this.totalDays,
    required this.startDate,
    required this.completedDays,
    this.lastReadPage,
    this.paused = false,
    this.reminderHour,
    this.reminderMinute,
  });

  int get pagesPerDay => (604 / totalDays).ceil();

  /// Calendar day since start (1-based, clamped to totalDays).
  int get currentDay {
    final start = DateTime.parse(startDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(start.year, start.month, start.day);
    return (today.difference(startDay).inDays + 1).clamp(1, totalDays);
  }

  /// First page for today's range.
  /// If already completed today, shows the range that was just finished.
  int get todayStartPage {
    if (completedDays >= currentDay) {
      // Already done today — show the completed range
      return min((currentDay - 1) * pagesPerDay + 1, 604);
    }
    return min(completedDays * pagesPerDay + 1, 604);
  }

  /// Last page for today — if behind schedule, includes accumulated pages.
  int get todayEndPage => min(currentDay * pagesPerDay, 604);

  /// Pages completed so far.
  int get completedPages => min(completedDays * pagesPerDay, 604);

  /// 0.0 – 1.0 progress based on actual completed days.
  double get overallProgress => completedPages / 604;

  bool get isComplete => completedPages >= 604;

  bool get hasReminder => reminderHour != null;

  DateTime get estimatedEndDate {
    final start = DateTime.parse(startDate);
    return start.add(Duration(days: totalDays - 1));
  }
}

const _kTotalDays = 'khatmah_total_days';
const _kStartDate = 'khatmah_start_date';
const _kCompletedDays = 'khatmah_completed_days';
const _kLastReadPage = 'khatmah_last_read_page';
const _kPaused = 'khatmah_paused';
const _kReminderHour = 'khatmah_reminder_hour';
const _kReminderMinute = 'khatmah_reminder_minute';

@Riverpod(keepAlive: true)
class KhatmahConfigNotifier extends _$KhatmahConfigNotifier {
  @override
  KhatmahConfig? build() {
    _loadFromPrefs();
    return null;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final totalDays = prefs.getInt(_kTotalDays);
    final startDate = prefs.getString(_kStartDate);
    if (totalDays == null || startDate == null) return;

    state = KhatmahConfig(
      totalDays: totalDays,
      startDate: startDate,
      completedDays: prefs.getInt(_kCompletedDays) ?? 0,
      lastReadPage: prefs.getInt(_kLastReadPage),
      paused: prefs.getBool(_kPaused) ?? false,
      reminderHour: prefs.getInt(_kReminderHour),
      reminderMinute: prefs.getInt(_kReminderMinute),
    );
  }

  Future<void> startKhatmah(int totalDays) async {
    AnalyticsService.event('Khatmah Created', props: {'days': '$totalDays'});
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setInt(_kTotalDays, totalDays);
    await prefs.setString(_kStartDate, today);
    await prefs.setInt(_kCompletedDays, 0);
    await prefs.remove(_kLastReadPage);
    state = KhatmahConfig(
      totalDays: totalDays,
      startDate: today,
      completedDays: 0,
      reminderHour: state?.reminderHour,
      reminderMinute: state?.reminderMinute,
    );
  }

  Future<void> onDayCompleted() async {
    if (state == null) return;
    AnalyticsService.event('Khatmah Day Completed');
    final prefs = await SharedPreferences.getInstance();
    final newCount = state!.completedDays + 1;
    await prefs.setInt(_kCompletedDays, newCount);
    state = KhatmahConfig(
      totalDays: state!.totalDays,
      startDate: state!.startDate,
      completedDays: newCount,
      lastReadPage: state!.lastReadPage,
      paused: state!.paused,
      reminderHour: state!.reminderHour,
      reminderMinute: state!.reminderMinute,
    );
  }

  Future<void> onDayUncompleted() async {
    if (state == null) return;
    final prefs = await SharedPreferences.getInstance();
    final newCount = (state!.completedDays - 1).clamp(0, state!.totalDays);
    await prefs.setInt(_kCompletedDays, newCount);
    state = KhatmahConfig(
      totalDays: state!.totalDays,
      startDate: state!.startDate,
      completedDays: newCount,
      lastReadPage: state!.lastReadPage,
      paused: state!.paused,
      reminderHour: state!.reminderHour,
      reminderMinute: state!.reminderMinute,
    );
  }

  Future<void> editKhatmah(int totalDays) async {
    if (state == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTotalDays, totalDays);
    state = KhatmahConfig(
      totalDays: totalDays,
      startDate: state!.startDate,
      completedDays: state!.completedDays,
      lastReadPage: state!.lastReadPage,
      paused: state!.paused,
      reminderHour: state!.reminderHour,
      reminderMinute: state!.reminderMinute,
    );
  }

  Future<void> pauseKhatmah() async {
    if (state == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPaused, true);
    state = KhatmahConfig(
      totalDays: state!.totalDays,
      startDate: state!.startDate,
      completedDays: state!.completedDays,
      lastReadPage: state!.lastReadPage,
      paused: true,
      reminderHour: state!.reminderHour,
      reminderMinute: state!.reminderMinute,
    );
  }

  Future<void> resumeKhatmah() async {
    if (state == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPaused, false);
    state = KhatmahConfig(
      totalDays: state!.totalDays,
      startDate: state!.startDate,
      completedDays: state!.completedDays,
      lastReadPage: state!.lastReadPage,
      paused: false,
      reminderHour: state!.reminderHour,
      reminderMinute: state!.reminderMinute,
    );
  }

  /// Called when the user reads a page within the khatmah range.
  Future<void> updateLastReadPage(int page) async {
    if (state == null) return;
    if (page < state!.todayStartPage || page > state!.todayEndPage) return;
    if (page == state!.lastReadPage) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastReadPage, page);
    state = KhatmahConfig(
      totalDays: state!.totalDays,
      startDate: state!.startDate,
      completedDays: state!.completedDays,
      lastReadPage: page,
      paused: state!.paused,
      reminderHour: state!.reminderHour,
      reminderMinute: state!.reminderMinute,
    );
  }

  Future<void> clearKhatmah() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTotalDays);
    await prefs.remove(_kStartDate);
    await prefs.remove(_kCompletedDays);
    await prefs.remove(_kLastReadPage);
    await prefs.remove(_kPaused);
    await prefs.remove(_kReminderHour);
    await prefs.remove(_kReminderMinute);
    state = null;
  }

  Future<void> setReminder(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kReminderHour, hour);
    await prefs.setInt(_kReminderMinute, minute);
    if (state != null) {
      state = KhatmahConfig(
        totalDays: state!.totalDays,
        startDate: state!.startDate,
        completedDays: state!.completedDays,
        lastReadPage: state!.lastReadPage,
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
      state = KhatmahConfig(
        totalDays: state!.totalDays,
        startDate: state!.startDate,
        completedDays: state!.completedDays,
        lastReadPage: state!.lastReadPage,
      );
    }
  }
}
