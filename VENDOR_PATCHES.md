# Vendored patches to `packages/imad_flutter`

`packages/imad_flutter` is a vendored path dependency of the upstream
[mushaf-imad-flutter](https://github.com/Itqan-community/mushaf-imad-flutter) library. Local
changes are recorded here so they survive a future upstream sync.

## 2026-08-07 — Full Surah reader

### 1. `lib/src/data/audio/reciter_data_provider.dart` — rewritten (bug fix)

**The bug.** The reciter list used an arbitrary id space that collided numerically with the
bundled timing assets in `assets/ayah_timing/read_<id>.json`. Those assets are keyed by
**mp3quran moshaf id**, and `DefaultAudioRepository` feeds the same int to both the reciter lookup
and the timing lookup. Every reciter therefore highlighted the wrong ayah.

Examples of the old mismatch:

| old id | list claimed | `read_<id>.json` actually was |
|---|---|---|
| 5 | Al-Minshawi `minsh` | Ahmad Al-Ajmy `ajm` |
| 31 | Al-Afasy `afs` | Saud Al-Shuraim `shur` |
| 51 | Maher Al-Muaiqly `maher` | Abdul Basit Mujawwad |
| 53 | Al-Sudais `sds` | Abdul Basit murattal |
| 118 | Bandar Baleela `bnd` (dead 404) | Al-Hussary `husr` |

Separately, 6 of the 18 hardcoded `folderUrl`s were dead 404s because mp3quran moves reciters
between numbered servers: `server11/taniji/`, `server10/bnd/`, `server11/bsfr/`, `server11/jhn/`,
`server10/mat/`, `server13/husr/Mujawwad/`.

**The fix.** The list is regenerated from `https://www.mp3quran.net/api/v3/ayat_timing/reads`,
keyed by real moshaf id with `folderUrl` copied verbatim from the API. This makes the audio URL
and the timing file structurally incapable of diverging: both are derived from the same id.

- 28 reciters, all with a complete 114-surah timing read.
- All 28 audio URLs verified live (`HTTP 206 audio/mpeg` on a range request for `018.mp3`).
- All 18 bundled `read_*.json` files verified to match their provider entry's `folderUrl` exactly.
- Default reciter is now Al-Afasy (id 123), the most requested.
- Added `bundledTimingIds`, the set of ids with a local timing asset. Ids outside it fetch timing
  from the API at runtime.
- `searchReciters` now matches Arabic **and** English names regardless of `languageCode`, and
  returns the full list for an empty query.

### 2. `lib/src/data/audio/flutter_audio_player.dart`

- Configure `audio_session` with `AudioSessionConfiguration.music()` so call interruptions and
  ducking behave. It was never configured anywhere in the repo.
- `stop()` now clears `_currentChapter` and `_currentReciterId` and rebroadcasts. Previously it
  kept emitting a chapter, so the mushaf highlight could stick on an ayah after stopping.
- Added `chapterCompletedStream`, used to auto-advance to the next surah.
- `loadChapter` accepts an optional `chapterTitle` so the lock-screen notification shows the real
  surah name instead of `Surah 018`.
- Removed the `print()` calls, several of which sat on the per-position-tick path.
- Playback errors now surface through the domain state instead of only being printed.

- Added `ChapterAudioSourceFactory`, a static hook the host app installs to supply a caching
  audio source. It lives in the app because on-disk caching needs `dart:io`, which would break
  this package's web support. Falls back to plain `AudioSource.uri` when unset or on web.

### 3. `lib/src/di/core_module.dart`

- `androidNotificationIcon: 'drawable/ic_stat_notification'`, reusing the monochrome status-bar
  icon the app already ships for `flutter_local_notifications`. It previously fell back to the
  full-colour launcher icon.
- `androidStopForegroundOnPause: false` so playback survives a pause in the background, with
  `androidNotificationOngoing: false` to satisfy audio_service's paired assertion.

### 4. `pubspec.yaml`

- Added `audio_session: ^0.2.2` explicitly. It was only present transitively via `audio_service`.

### 5. `lib/src/data/audio/ayah_timing_service.dart`

Added a `remoteFetcher` hook so ids outside `bundledTimingIds` resolve timing from the
mp3quran API, with a per-chapter cache and in-flight de-duplication.

`getCurrentVerse` no longer awaits the network. It reads the cache and returns null on a miss
while kicking off a background fetch. Previously it awaited a request on every position tick,
which stalled the player state stream and prevented playback from ever starting for
non-bundled reciters. Empty results are cached so a reciter without timing does not refetch
on every tick.

### 6. `lib/src/data/repository/default_audio_repository.dart`, `lib/src/domain/repository/audio_repository.dart`, `lib/imad_flutter.dart`

Widened `AudioRepository` with chapter-level playback: `loadChapter` takes a `chapterTitle`
for the lock screen, plus `getChapterCompletedStream`, `getChapterTimings` and
`preloadTiming`. Exported `verse_data_provider.dart` and `surah_frame.dart`.

## 2026-08-07 — Landscape reading and highlight rework

### 7. `lib/src/ui/mushaf/quran_page_widget.dart`

Extracted `_buildLine` and added a landscape branch. Portrait keeps the 15 equal `Expanded`
line slots. Landscape sizes each line from the image aspect ratio, crops to
`_landscapeLineCrop = 0.80` of the slot height, and scrolls vertically. The crop is a safety
floor against a measured global maximum ink fraction of 0.754, so no glyph is clipped.

`QuranLineImage._aspectRatio` was promoted to public `aspectRatio` for this.

### 8. `lib/src/ui/mushaf/quran_line_image.dart`

Audio highlights previously passed an opaque colour into a `BlendMode.srcIn` path, which
recoloured the glyphs themselves. They now draw translucent bands behind the text like the
selection highlight, via a shared `_buildHighlightBands`. Stack order is frame, selection
bands, audio bands, base image, markers. The now-dead `_VerseClipper` was removed.

### 9. `lib/src/ui/mushaf/surah_frame.dart` — new file

Surah header frame used by the page widget.

## Not patched

The Nastaleeq reader in `apps/mobile/lib/features/reader/widgets/nastaleeq_page_view.dart`
deliberately lives in the app, not here. It consumes the already-exported
`VerseDataProvider` for page-mapped Uthmani text and `VerseFasel` for ayah medallions, so it
adds no further vendor surface.
