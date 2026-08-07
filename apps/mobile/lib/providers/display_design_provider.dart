import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'display_design_provider.g.dart';

const _kDisplayDesignKey = 'display_design_mode';

enum ReaderDisplayMode { immersive, alwaysVisible }

@Riverpod(keepAlive: true)
class DisplayDesignMode extends _$DisplayDesignMode {
  @override
  ReaderDisplayMode build() {
    _loadFromPrefs();
    return ReaderDisplayMode.immersive;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kDisplayDesignKey);
    if (stored != null) {
      state = ReaderDisplayMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => ReaderDisplayMode.immersive,
      );
    }
  }

  Future<void> setMode(ReaderDisplayMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDisplayDesignKey, mode.name);
  }
}
