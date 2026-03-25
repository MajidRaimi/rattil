import 'package:plausible/plausible.dart';

class AnalyticsService {
  static final _analytics = Plausible(
    domain: 'rattil.app',
    server: Uri.parse('https://analytics.rattil.app'),
  );

  static Future<void> screenView(String screen) async {
    try {
      await _analytics.send(path: '/app/$screen', props: {'platform': 'mobile'});
    } catch (_) {}
  }

  static Future<void> event(String name, {Map<String, String>? props}) async {
    try {
      final allProps = {'platform': 'mobile', ...?props};
      await _analytics.send(event: name, path: '/app', props: allProps);
    } catch (_) {}
  }
}
