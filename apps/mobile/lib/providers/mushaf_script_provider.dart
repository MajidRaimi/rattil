import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'mushaf_script_provider.g.dart';

const _kMushafScriptKey = 'mushaf_script';

enum MushafScript { madinah, nastaleeq, nastaleeqKfgqpc }

@Riverpod(keepAlive: true)
class MushafScriptMode extends _$MushafScriptMode {
  @override
  MushafScript build() {
    _loadFromPrefs();
    return MushafScript.madinah;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kMushafScriptKey);
    if (stored == null) return;
    state = MushafScript.values.firstWhere(
      (s) => s.name == stored,
      orElse: () => MushafScript.madinah,
    );
  }

  Future<void> setScript(MushafScript script) async {
    if (state == script) return;
    state = script;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMushafScriptKey, script.name);
  }
}
