<p align="center">
  <img src="apps/mobile/assets/app_icon.png" width="120" alt="Rattil" />
</p>

<h1 align="center">رتّل — Rattil</h1>

<p align="center">
  <em>أَوْ زِدْ عَلَيْهِ وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا</em>
  <br/>
  <sub>المزمل - ٤</sub>
</p>

<p align="center">
  Your companion for reading and memorizing the Holy Quran.
  <br/>
  Free, offline-first, no accounts, no tracking.
</p>

<p align="center">
  <a href="https://rattil.app">Website</a> · <a href="PRIVACY_POLICY.md">Privacy Policy</a> · <a href="mailto:majidsraimi@gmail.com">Contact</a>
</p>

---

## Features

- **Quran Reader**: Complete Quran in Uthmanic Hafs script, 604 pages, fully offline, plus the Nastaleeq (Indo-Pak) script in two editions: DigitalKhatt IndoPak (the printed 15-line, 610-page Indo-Pak layout) and the King Fahd Complex's Hafs Nastaleeq (flowing over the 604 Madinah pages)
- **Search**: Find any surah or verse by Arabic text or surah name
- **Bookmarks**: Save and organize verses for easy reference
- **Hifz Tracking**: Track memorization progress juz by juz, page by page
- **Wird**: Set daily reading goals with reminders and track consistency
- **Tikrar**: Memorize verses through structured repetition with audio recitation
- **Tasmi'**: AI-powered recitation verification *(coming soon)*
- **44 Languages**: Full interface localization
- **Home Widget**: iOS widget displaying a random Quran verse, updated hourly
- **Dark & Light Theme**: System-aware with manual toggle
- **Privacy**: No accounts, no tracking, no ads, no analytics. All data stays on your device.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.38, Riverpod, GoRouter |
| Database | SQLite (sqflite) — bundled Quran data |
| API | FastAPI (Python) — Tasmi' transcription service |
| AI Model | [tarteel-ai/whisper-base-ar-quran](https://huggingface.co/tarteel-ai/whisper-base-ar-quran) |
| Web | Next.js 16, Tailwind CSS v4, Tolgee i18n |
| Fonts | UthmanicHafs (Madinah), DigitalKhatt IndoPak and KFGQPC Hafs Nastaleeq (Nastaleeq), NeueFrutigerWorld (UI) |
| Monorepo | Turborepo, Bun |

## Project Structure

```
apps/
  mobile/     # Flutter app (iOS + Android)
  api/        # FastAPI — Tasmi' transcription service
  web/        # Next.js landing page (rattil.app)
```

## Getting Started

### Prerequisites

- Flutter SDK 3.38+
- Bun 1.0+
- Python 3.12+ with [uv](https://docs.astral.sh/uv/) (for API)
- Docker (optional)

### Mobile

```bash
cd apps/mobile
flutter pub get
flutter run
```

### Web

```bash
cd apps/web
bun install
bun dev
```

### API

```bash
cd apps/api
uv sync
uv run fastapi dev app/main.py
```

The API downloads the Whisper model on first run (~300MB).

### Code Generation

After modifying Freezed models or Riverpod providers:

```bash
cd apps/mobile
dart run build_runner build --delete-conflicting-outputs
```

## Design

| Token | Value |
|-------|-------|
| Gold | `#D4A843` |
| Background (light) | `#F7F5F0` |
| Background (dark) | `#0D0D0D` |
| Surface (light) | `#FFFFFF` |
| Surface (dark) | `#1A1A1A` |
| Quran font | UthmanicHafs (Madinah), DigitalKhatt IndoPak or KFGQPC Hafs Nastaleeq (Nastaleeq) |
| UI font | NeueFrutigerWorld (400/500/700) |
| Border radius | 16px (cards), 12px (secondary), 8px (small) |

## Privacy

Rattil does not collect, store, or transmit any personal data. No accounts, no analytics, no tracking, no ads. All reading progress, bookmarks, and preferences are stored locally on your device. See [Privacy Policy](PRIVACY_POLICY.md).

## License

The Quran text and fonts bundled with the app come from these sources, each under its own licence:

- **DigitalKhatt IndoPak text**: the DigitalKhatt IndoPak 15-line text, Copyright (c) 2020–present DigitalKhatt contributors, MIT License ([digitalkhatt-js](https://github.com/DigitalKhatt/digitalkhatt-js)). The reader uses its 15-line Indo-Pak page and line layout (610 pages) from the same pinned source. Notice in `apps/mobile/assets/quran/indopak-digitalkhatt-LICENSE.txt`.
- **DigitalKhatt IndoPak font**: Copyright (c) 2024-2025 Amine Anane, Copyright (c) 2024-2025 Tarteel Inc., SIL Open Font License 1.1 ([indopakfont](https://github.com/DigitalKhatt/indopakfont)). Licence in `apps/mobile/assets/fonts/DigitalKhattIndoPak-OFL.txt`.
- **KFGQPC Hafs Nastaleeq font and text**: from the King Fahd Glorious Quran Printing Complex (`HafsNastaleeq-Ver10.zip`), used under the KFGQPC licence. The font is shipped unmodified. The text keeps the published letters, vowel marks and pause signs, with the display-only normalisations listed in the provenance notice (collapsed whitespace, a no-break space before each ayah number, and a combining grapheme joiner in eight verses). Licence in `apps/mobile/assets/fonts/HafsNastaleeq-LICENSE.txt`, provenance in `apps/mobile/assets/quran/indopak-kfgqpc-NOTICE.txt`.

See the remaining font licences in `apps/mobile/assets/fonts/`.

---

<p align="center">
  <sub>صدقة جارية لأمي وأمهات المسلمين، رحمهن الله</sub>
</p>
