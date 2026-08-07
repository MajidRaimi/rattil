class AudioFocus {
  AudioFocus._();

  static const surahPlayer = 'surah_player';
  static const hifzPlayer = 'hifz_player';
  static const reciterPreview = 'reciter_preview';
  static const tafseerPlayer = 'tafseer_player';
  static const tasmiRecorder = 'tasmi_recorder';

  static final Map<String, Future<void> Function()> _stoppers = {};

  static void register(String owner, Future<void> Function() stop) {
    _stoppers[owner] = stop;
  }

  static void unregister(String owner) {
    _stoppers.remove(owner);
  }

  static Future<void> claim(String owner) async {
    final others = _stoppers.entries
        .where((entry) => entry.key != owner)
        .toList();
    for (final entry in others) {
      try {
        await entry.value();
      } catch (_) {}
    }
  }
}
