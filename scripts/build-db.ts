/**
 * build-db.ts
 *
 * Fetches Quran data from the quran.com v4 API and builds a pre-populated
 * SQLite database for the mobile app.
 *
 * Usage:  bun run scripts/build-db.ts
 */

import { Database } from "bun:sqlite";
import { mkdirSync, existsSync, unlinkSync } from "node:fs";
import { dirname } from "node:path";

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

const DB_PATH =
  new URL("../apps/mobile/assets/db/quran.db", import.meta.url).pathname;

const API_BASE = "https://api.quran.com/api/v4";
const TRANSLATION_RESOURCE_ID = 20; // Saheeh International
const DELAY_MS = 100;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function sleep(ms: number) {
  return new Promise((r) => setTimeout(r, ms));
}

async function fetchJson<T>(url: string): Promise<T> {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`HTTP ${res.status} for ${url}: ${await res.text()}`);
  }
  return res.json() as Promise<T>;
}

// ---------------------------------------------------------------------------
// API response types (only the fields we need)
// ---------------------------------------------------------------------------

interface ApiChapter {
  id: number;
  name_arabic: string;
  name_simple: string;
  translated_name: { name: string };
  revelation_place: string;
  verses_count: number;
}

interface ApiVerse {
  verse_key: string; // "1:1"
  text_uthmani?: string;
  text_imlaei?: string;
  text?: string;
  juz_number?: number;
  hizb_number?: number;
  page_number?: number;
}

interface ApiTranslationVerse {
  verse_key: string;
  translation: { text: string };
}

// A combined row we accumulate per ayah before inserting
interface AyahRow {
  surah_number: number;
  ayah_number: number;
  text_uthmani: string;
  text_simple: string;
  juz: number;
  hizb: number;
  page: number;
}

// ---------------------------------------------------------------------------
// Schema
// ---------------------------------------------------------------------------

const SCHEMA = `
-- Read-only tables (pre-populated)
CREATE TABLE surahs (
  number INTEGER PRIMARY KEY,
  name_arabic TEXT NOT NULL,
  name_english TEXT NOT NULL,
  name_translation TEXT NOT NULL,
  revelation_type TEXT NOT NULL,
  ayah_count INTEGER NOT NULL
);

CREATE TABLE ayahs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  text_uthmani TEXT NOT NULL,
  text_simple TEXT NOT NULL,
  juz INTEGER NOT NULL,
  hizb INTEGER NOT NULL,
  page INTEGER NOT NULL,
  FOREIGN KEY (surah_number) REFERENCES surahs(number),
  UNIQUE(surah_number, ayah_number)
);

CREATE TABLE translations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  language TEXT NOT NULL DEFAULT 'en',
  translator TEXT NOT NULL DEFAULT 'Saheeh International',
  text TEXT NOT NULL,
  FOREIGN KEY (surah_number) REFERENCES surahs(number)
);

-- FTS5 virtual tables for search
CREATE VIRTUAL TABLE ayahs_fts USING fts5(
  text_simple,
  content='ayahs',
  content_rowid='id'
);

CREATE VIRTUAL TABLE translations_fts USING fts5(
  text,
  content='translations',
  content_rowid='id'
);

-- User data tables (created empty)
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(surah_number, ayah_number)
);

CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  text TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE reading_progress (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  surah_number INTEGER NOT NULL DEFAULT 1,
  ayah_number INTEGER NOT NULL DEFAULT 1,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT INTO reading_progress (id, surah_number, ayah_number) VALUES (1, 1, 1);
`;

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  // Ensure output directory exists
  const dir = dirname(DB_PATH);
  if (!existsSync(dir)) {
    mkdirSync(dir, { recursive: true });
  }

  // Remove old DB if it exists
  if (existsSync(DB_PATH)) {
    unlinkSync(DB_PATH);
    console.log("Removed existing database.");
  }

  console.log(`Creating database at ${DB_PATH}`);
  const db = new Database(DB_PATH);
  db.exec("PRAGMA journal_mode = WAL;");
  db.exec("PRAGMA foreign_keys = ON;");

  // Create schema
  db.exec(SCHEMA);
  console.log("Schema created.\n");

  // ------------------------------------------------------------------
  // 1. Fetch and insert surahs (chapters)
  // ------------------------------------------------------------------
  console.log("Fetching chapters list...");
  const chaptersRes = await fetchJson<{ chapters: ApiChapter[] }>(
    `${API_BASE}/chapters?language=en`
  );
  const chapters = chaptersRes.chapters;

  const insertSurah = db.prepare(
    `INSERT INTO surahs (number, name_arabic, name_english, name_translation, revelation_type, ayah_count)
     VALUES (?, ?, ?, ?, ?, ?)`
  );

  db.exec("BEGIN TRANSACTION");
  for (const ch of chapters) {
    insertSurah.run(
      ch.id,
      ch.name_arabic,
      ch.name_simple,
      ch.translated_name.name,
      ch.revelation_place,
      ch.verses_count
    );
  }
  db.exec("COMMIT");
  console.log(`Inserted ${chapters.length} surahs.\n`);

  // ------------------------------------------------------------------
  // 2. For each surah, fetch ayah data and translations
  // ------------------------------------------------------------------
  const insertAyah = db.prepare(
    `INSERT INTO ayahs (surah_number, ayah_number, text_uthmani, text_simple, juz, hizb, page)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  );

  const insertTranslation = db.prepare(
    `INSERT INTO translations (surah_number, ayah_number, language, translator, text)
     VALUES (?, ?, 'en', 'Saheeh International', ?)`
  );

  for (const ch of chapters) {
    const n = ch.id;
    process.stdout.write(
      `[${String(n).padStart(3, " ")}/114] ${ch.name_simple.padEnd(20)} `
    );

    // Fetch uthmani text
    const uthmaniRes = await fetchJson<{ verses: ApiVerse[] }>(
      `${API_BASE}/quran/verses/uthmani?chapter_number=${n}`
    );
    await sleep(DELAY_MS);

    // Fetch simple (imlaei) text
    const simpleRes = await fetchJson<{ verses: ApiVerse[] }>(
      `${API_BASE}/quran/verses/imlaei?chapter_number=${n}`
    );
    await sleep(DELAY_MS);

    // Fetch verse metadata (juz, hizb, page)
    const metaRes = await fetchJson<{ verses: ApiVerse[] }>(
      `${API_BASE}/verses/by_chapter/${n}?fields=verse_key,juz_number,hizb_number,page_number&per_page=300`
    );
    await sleep(DELAY_MS);

    // Fetch translation
    const transRes = await fetchJson<{
      translations: { resource_id: number; verse_key: string; text: string }[];
    }>(`${API_BASE}/quran/translations/${TRANSLATION_RESOURCE_ID}?chapter_number=${n}`);
    await sleep(DELAY_MS);

    // Build lookup maps keyed by verse_key "N:M"
    const uthmaniMap = new Map<string, string>();
    for (const v of uthmaniRes.verses) {
      uthmaniMap.set(v.verse_key, v.text_uthmani ?? "");
    }

    const simpleMap = new Map<string, string>();
    for (const v of simpleRes.verses) {
      simpleMap.set(v.verse_key, v.text_imlaei ?? v.text ?? "");
    }

    const metaMap = new Map<
      string,
      { juz: number; hizb: number; page: number }
    >();
    for (const v of metaRes.verses) {
      metaMap.set(v.verse_key, {
        juz: v.juz_number ?? 0,
        hizb: v.hizb_number ?? 0,
        page: v.page_number ?? 0,
      });
    }

    const transMap = new Map<string, string>();
    for (const t of transRes.translations) {
      transMap.set(t.verse_key, stripHtml(t.text));
    }

    // Insert into DB in a transaction per surah
    db.exec("BEGIN TRANSACTION");
    for (let ayah = 1; ayah <= ch.verses_count; ayah++) {
      const key = `${n}:${ayah}`;
      const meta = metaMap.get(key) ?? { juz: 0, hizb: 0, page: 0 };

      insertAyah.run(
        n,
        ayah,
        uthmaniMap.get(key) ?? "",
        simpleMap.get(key) ?? "",
        meta.juz,
        meta.hizb,
        meta.page
      );

      const translationText = transMap.get(key) ?? "";
      if (translationText) {
        insertTranslation.run(n, ayah, translationText);
      }
    }
    db.exec("COMMIT");

    process.stdout.write(`${ch.verses_count} ayahs\n`);
  }

  // ------------------------------------------------------------------
  // 3. Populate FTS5 tables
  // ------------------------------------------------------------------
  console.log("\nPopulating FTS5 index for ayahs...");
  db.exec(
    `INSERT INTO ayahs_fts(rowid, text_simple)
     SELECT id, text_simple FROM ayahs;`
  );

  console.log("Populating FTS5 index for translations...");
  db.exec(
    `INSERT INTO translations_fts(rowid, text)
     SELECT id, text FROM translations;`
  );

  // ------------------------------------------------------------------
  // 4. Final optimisations
  // ------------------------------------------------------------------
  console.log("Running VACUUM...");
  db.exec("VACUUM;");

  db.close();

  const stat = Bun.file(DB_PATH);
  const sizeMb = ((await stat.size) / 1024 / 1024).toFixed(2);
  console.log(`\nDone! Database size: ${sizeMb} MB`);
  console.log(`Output: ${DB_PATH}`);
}

/** Strip basic HTML tags that the translation API sometimes returns. */
function stripHtml(text: string): string {
  return text.replace(/<[^>]*>/g, "").trim();
}

// Run
main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
