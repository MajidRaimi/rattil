import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'tutorial_provider.g.dart';

const _kTutorialCompletedKey = 'tutorial_completed';

@Riverpod(keepAlive: true)
class TutorialStatus extends _$TutorialStatus {
  @override
  bool build() {
    _loadFromPrefs();
    return true; // default true so existing users never see the tutorial
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_kTutorialCompletedKey)) {
      // First-time user — key is missing
      state = false;
    } else {
      state = prefs.getBool(_kTutorialCompletedKey) ?? true;
    }
  }

  Future<void> markCompleted() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTutorialCompletedKey, true);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTutorialCompletedKey);
    state = false;
  }
}
