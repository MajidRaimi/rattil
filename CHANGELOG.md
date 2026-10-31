# Changelog

## v1.5.2

### Nastaleeq script, done properly

The Nastaleeq reader in v1.5.0 never showed a Nastaleeq mushaf. It now offers two real
Indo-Pak editions, each with its own font and its own text. Settings > Display > خط المصحف
lists three scripts:

- **Madinah Mushaf**: unchanged.
- **Nastaleeq**: the DigitalKhatt IndoPak font with the DigitalKhatt IndoPak 15-line text.
  This is the default Nastaleeq edition and the closest to the printed page: a heavy pen,
  Indo-Pak spelling, Urdu-form digits, and the full set of waqf, ruku', sajda and sakt signs.
  The font is OFL 1.1 and the text is MIT. Al-Fatiha is numbered to the Hafs count.
- **Nastaleeq (King Fahd Complex)**: KFGQPC's Hafs Nastaleeq font with KFGQPC's own text
  from the same release, shipped as published. Its pen is lighter, close to the Madinah look.

Anyone who had Nastaleeq selected stays on Nastaleeq and gets the DigitalKhatt edition.

The DigitalKhatt edition now follows the printed Indo-Pak 15-line mushaf: 610 pages with
the printed line breaks, 15 equal lines on every page, and every line justified edge to edge.
Surah titles and the basmala each take one line, as in print. The King Fahd Complex edition
keeps the flowing layout over the 604 Madinah pages.

Ayah markers now come from the text and font, so each verse ends in the edition's own
medallion and number instead of the Madinah medallion. The rest of the app still counts in
the 604 Madinah pages: each printed DigitalKhatt page is mapped to a Madinah page by verse,
so bookmarks, search, audio follow-along and switching editions stay on the same verse.
The page label and page picker show the printed page out of 610 in the DigitalKhatt edition,
and opening a surah lands on the printed page that shows its title.

Justified lines are filled the way the print fills them: by kashida, stretching the joins
between letters, instead of widening the gaps between words. Stretches go where a scribe
would put them first (after س ش ص ض, before a final ه or ة), at most three tatweels per
join, and never inside a vowel-mark cluster, after a letter that does not join forward,
through lam-alef or the word Allah, or in the opening letters of a surah. The stretch
points are computed ahead of time by shaping every word with the font, by
`scripts/indopak-kashida` (run with `uv run python build_kashida_table.py`).

Neither edition shows a sajda mark at 22:77, matching the King Fahd Complex print. Every
other sajda, ruku', waqf and sakt sign is kept.

The script description is rewritten in all 44 languages. It used to say the script came from
the King Fahd Complex, which is now true only of the second edition.

### Corrections to v1.5.0

The v1.5.0 notes were wrong on two points, and an unreleased fix made things worse.

- **The text.** The notes said Nastaleeq mode reused the Uthmani text. It did not. It read
  the imla'i field of the bundled verse data: modern spelling with partial tashkeel and no
  Indo-Pak orthography or signs. That is why the page looked like plain modern Naskh.
- **The font.** KFGQPC's Hafs Nastaleeq was the right kind of typeface. In Quran printing,
  "Nastaleeq" names the South Asian Indo-Pak mushaf, a Naskh-family hand on a flat ruled
  baseline, not Persian or Urdu cascading Nasta'liq. KFGQPC titles the font the computer
  Naskh face for their مصحف نستعليق edition. The fault was pairing it with text it was not
  built for: an Indo-Pak font only renders correctly with its own text encoding.
- **The interim fix.** An unreleased change swapped the font for Noto Nastaliq Urdu, a
  cascading Urdu Nasta'liq. That is the wrong script family for a mushaf, and it was still
  fed the same imla'i text. It has been removed.

The draft request to KFGQPC for permission to ship their Nastaleeq page images is also
removed. This approach renders text and does not use page images.

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
