# Changelog

## v1.5.1

Raised the minimum supported iOS version from 13.0 to 15.0.

Apple returned ITMS-90068 on the 1.5.0 delivery: from Spring 2027 every iOS app must
declare a minimum of 15.0 or later to be uploaded or submitted. The Runner target was
inheriting 13.0 from three project-level build configurations, and the `platform :ios`
line in the Podfile was commented out so CocoaPods enforced no floor either. Both are now
set to 15.0. The widget extension was already at 17.0 and is unchanged.

iOS 15 runs on the iPhone 6s and later, so this drops only iPhone 6 and older.

## v1.5.0

### Nastaleeq mushaf script

The reader can now be shown in Nastaleeq. Settings > Display > خط المصحف offers the
existing Madinah page images or the new Nastaleeq script.

The font is KFGQPC's official رواية حفص نستعليق, taken from the King Fahd Complex, the
same typeface used in their printed Nastaleeq mushaf. It is shipped unmodified alongside
its licence. Nastaleeq mode reuses the Uthmani text already bundled with the app, so page
boundaries stay identical to the image mushaf and bookmarks, search and audio follow-along
continue to line up.

Each page is sized to fit one screen exactly, with no scrolling. Verse long-press, verse
selection, audio follow-along highlighting and page turning all work in both modes, and
ayah markers use the same medallion in each.

### Full surah playback

Long-press a surah name in the reader header to pick a reciter and play the whole surah.
The player bar expands into a control panel with a start and end ayah, a choice of what
happens at the end (next surah, repeat, or stop), and mid-surah reciter switching that
keeps your place by ayah rather than by timestamp.

Playback continues in the background with lock screen and notification controls. Audio is
cached on first listen so a surah replays offline.

Reciters come from a bundled list plus search against the mp3quran catalogue, with verse
timing data bundled for 18 reciters and fetched on demand for the rest.

### Landscape reading

The reader now rotates to landscape, filling the width and scrolling vertically, for
easier reading at a larger size.

### Display settings

A new Display page controls whether reader chrome hides automatically or stays pinned.

### Fixes

- Corrected reciter identifiers that were mismatched against bundled timing data, which
  had caused the wrong ayah to be highlighted during playback, and replaced six dead
  audio URLs.
- Verse highlighting during playback now draws a translucent band behind the text rather
  than recolouring the glyphs.
- Completed 37 missing translation keys across 42 languages. Buttons including cancel,
  save, done, delete and create previously rendered as raw key names in those languages.
- Translated 24 further keys that had been left as English, covering the display settings
  and the whole surah player panel.

Note that many older keys across those 42 languages are still English. This release does
not address that, and those languages remain only partly localised.
