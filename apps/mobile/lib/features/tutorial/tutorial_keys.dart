import 'package:flutter/material.dart';
import '../hifz/profile_screen.dart';

class TutorialKeys {
  TutorialKeys._();

  // Phase 1: Navigation Bar
  static final bottomBar = GlobalKey();
  static final searchTab = GlobalKey();
  static final bookmarksTab = GlobalKey();
  static final quranTab = GlobalKey();
  static final hifzTab = GlobalKey();
  static final settingsTab = GlobalKey();

  // Phase 2: Quran Reader Controls
  static final readerArea = GlobalKey();
  static final pageNumber = GlobalKey();
  static final surahName = GlobalKey();
  static final juzLabel = GlobalKey();

  // Phase 3–5: Profile tabs (each shown as a separate phase)
  static final profileScreen = GlobalKey<ProfileScreenState>();
  static final profileTabs = GlobalKey();
  static final wirdContent = GlobalKey();
  static final progressContent = GlobalKey();

  static List<GlobalKey> get phase1Steps => [
        bottomBar,
        quranTab,
        searchTab,
        bookmarksTab,
        hifzTab,
        settingsTab,
      ];

  static List<GlobalKey> get phase2Steps => [
        readerArea,
        pageNumber,
        surahName,
        juzLabel,
      ];

  // Phase 3: Hifz tab overview
  static List<GlobalKey> get phase3Steps => [profileTabs];

  // Phase 4: Wird tab
  static List<GlobalKey> get phase4Steps => [wirdContent];

  // Phase 5: Progress tab
  static List<GlobalKey> get phase5Steps => [progressContent];
}
