# Rattil

Offline-first Quran reading app built with Flutter. Beautiful dark UI, Uthmanic Arabic typography, and instant access to every ayah — no internet required.

## Overview

Rattil bundles the complete Quran text (Uthmanic script + simplified Arabic), English translations (Saheeh International), and full-text search in a local SQLite database. Audio recitation streams from CDN via a lightweight Elysia API.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter, Riverpod (code-gen), GoRouter |
| Data | SQLite (sqflite) with FTS5 search |
| API | Elysia (Bun) — audio metadata only |
| Fonts | KFGQPC Uthmanic Hafs, Amiri |
| Monorepo | Turborepo |

## Project Structure

```
apps/
  mobile/          # Flutter app (iOS + Android)
  api/             # Elysia API server (Bun)
scripts/
  build-db.ts      # Fetches Quran data and builds SQLite DB
```

## Getting Started

### Prerequisites

- Flutter SDK 3.10+
- Bun 1.0+
- Node.js 18+ (for Turborepo)

### Setup

```bash
# Install dependencies
bun install

# Build the Quran database (fetches from quran.com API)
bun run build:db

# Run the API
cd apps/api && bun run dev

# Run the mobile app
cd apps/mobile && flutter pub get && flutter run
```

### Code Generation

After modifying Freezed models or Riverpod providers:

```bash
cd apps/mobile
dart run build_runner build --delete-conflicting-outputs
```

## Features

- **Offline reading** — Full Quran text bundled in SQLite, works without internet
- **Uthmanic script** — Authentic KFGQPC Uthmanic Hafs font with generous line height
- **Search** — FTS5 full-text search across Arabic text and English translations
- **Bookmarks & Notes** — Save and annotate ayahs locally
- **Audio recitation** — Stream from popular reciters with background playback
- **Dark-first UI** — Near-black theme with gold accents, designed for long reading sessions

## Design

- Background: `#0D0D0D`
- Gold accent: `#D4A843`
- Arabic text: KFGQPC Uthmanic Hafs (Quranic), Amiri (UI)
- Material 3 dark theme

## Data Sources

- Quran text: [quran.com API v4](https://api-docs.quran.com/)
- Translation: Saheeh International (resource ID 20)
- Fonts: KFGQPC Uthmanic Script HAFS, Google Fonts Amiri

## License

All Quran text is in the public domain. See individual font licenses in `assets/fonts/`.
