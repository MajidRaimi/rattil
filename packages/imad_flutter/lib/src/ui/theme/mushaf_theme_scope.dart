import 'package:flutter/material.dart';

import 'reading_theme.dart';

/// A [ChangeNotifier] that holds the current [ReadingTheme] for the Mushaf.
///
/// Place a [MushafThemeScope] at the top of your widget tree, and all
/// child widgets (e.g. [MushafPageView], [ThemePickerWidget]) will
/// automatically share and react to theme changes.
class MushafThemeNotifier extends ChangeNotifier {
  ReadingTheme _readingTheme;

  MushafThemeNotifier({ReadingTheme initialTheme = ReadingTheme.light})
    : _readingTheme = initialTheme;

  /// The currently selected reading theme.
  ReadingTheme get readingTheme => _readingTheme;

  /// Convenience getter for the resolved theme data.
  ReadingThemeData get themeData => ReadingThemeData.fromTheme(_readingTheme);

  /// Update the reading theme. Notifies all listeners.
  void setTheme(ReadingTheme theme) {
    if (_readingTheme != theme) {
      _readingTheme = theme;
      notifyListeners();
    }
  }
}

/// An [InheritedNotifier] that provides a [MushafThemeNotifier] to the widget
/// tree, so all Mushaf widgets can share and react to theme changes.
///
/// ### Usage
///
/// Wrap your app (or a subtree) with [MushafThemeScope]:
///
/// ```dart
/// final themeNotifier = MushafThemeNotifier();
///
/// @override
/// Widget build(BuildContext context) {
///   return MushafThemeScope(
///     notifier: themeNotifier,
///     child: MaterialApp(...),
///   );
/// }
/// ```
///
/// Then in any descendant widget, read the current theme:
///
/// ```dart
/// final theme = MushafThemeScope.of(context);
/// final data = theme.themeData; // ReadingThemeData
/// ```
class MushafThemeScope extends InheritedNotifier<MushafThemeNotifier> {
  const MushafThemeScope({
    super.key,
    required MushafThemeNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Obtain the nearest [MushafThemeNotifier] from the widget tree.
  ///
  /// Throws if no [MushafThemeScope] ancestor is found.
  static MushafThemeNotifier of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<MushafThemeScope>();
    assert(scope != null, 'No MushafThemeScope found in widget tree');
    return scope!.notifier!;
  }

  /// Obtain the nearest [MushafThemeNotifier], or `null` if none exists.
  static MushafThemeNotifier? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MushafThemeScope>()
        ?.notifier;
  }
}
