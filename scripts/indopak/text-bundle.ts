import { missingCodePoints } from "./font-cmap.ts";
import { invariant } from "./invariant.ts";
import { assertPrintedLayout, type PrintedPage } from "./printed-layout.ts";
import {
  fromArabicIndicDigits,
  HAFS_VERSE_COUNTS,
  RLO,
  SURAH_COUNT,
  TAKHALLUS,
  VERSE_TOTAL,
  verseKey,
} from "./quran-constants.ts";

export interface IndoPakTextBundle {
  source: string;
  basmala: string;
  titles: string[];
  surahs: string[][];
  pages?: PrintedPage[];
}

export interface EditionRules {
  name: string;
  embeddedNumber: RegExp;
  guardedTail: RegExp;
  cmap: ReadonlySet<number>;
  absentFromFont: ReadonlySet<string>;
  printedPages: boolean;
}

export type VerseMap = Map<string, string>;

export function groupBySurah(verses: VerseMap): string[][] {
  return HAFS_VERSE_COUNTS.map((count, surahIndex) =>
    Array.from({ length: count }, (_, ayahIndex) => {
      const key = verseKey(surahIndex + 1, ayahIndex + 1);
      const text = verses.get(key);
      invariant(text !== undefined, `missing verse ${key}`);
      return text;
    }),
  );
}

export function flattenBundle(bundle: IndoPakTextBundle): Record<string, string> {
  return Object.fromEntries(
    bundle.surahs.flatMap((ayat, surahIndex) =>
      ayat.map((text, ayahIndex) => [verseKey(surahIndex + 1, ayahIndex + 1), text] as const),
    ),
  );
}

function assertRenderable(rules: EditionRules, label: string, text: string): void {
  const missing = missingCodePoints(text, rules.cmap, rules.absentFromFont);
  invariant(missing.length === 0, `${rules.name} ${label}: code points not in font cmap: ${missing.join(" ")}`);
  invariant(!text.includes(RLO), `${rules.name} ${label}: contains U+202E`);
  invariant(!text.includes(TAKHALLUS), `${rules.name} ${label}: contains U+0614`);
}

export function validateBundle(bundle: IndoPakTextBundle, rules: EditionRules): void {
  invariant(bundle.titles.length === SURAH_COUNT, `${rules.name}: ${bundle.titles.length} titles`);
  invariant(bundle.surahs.length === SURAH_COUNT, `${rules.name}: ${bundle.surahs.length} surahs`);
  const total = bundle.surahs.reduce((sum, ayat) => sum + ayat.length, 0);
  invariant(total === VERSE_TOTAL, `${rules.name}: ${total} verses`);
  invariant(
    (bundle.pages !== undefined) === rules.printedPages,
    `${rules.name}: printed pages ${rules.printedPages ? "missing" : "unexpected"}`,
  );
  if (bundle.pages !== undefined) {
    assertPrintedLayout(bundle.pages, bundle.surahs);
  }
  assertRenderable(rules, "basmala", bundle.basmala);
  bundle.titles.forEach((title, index) => assertRenderable(rules, `title ${index + 1}`, title));
  bundle.surahs.forEach((ayat, surahIndex) => {
    invariant(ayat.length === HAFS_VERSE_COUNTS[surahIndex], `${rules.name}: surah ${surahIndex + 1} count`);
    ayat.forEach((text, ayahIndex) => {
      const key = verseKey(surahIndex + 1, ayahIndex + 1);
      assertRenderable(rules, key, text);
      invariant(rules.guardedTail.test(text), `${rules.name} ${key}: medallion tail not NBSP-guarded`);
      const digits = rules.embeddedNumber.exec(text)?.[1];
      invariant(digits !== undefined, `${rules.name} ${key}: no embedded ayah number`);
      invariant(fromArabicIndicDigits(digits) === ayahIndex + 1, `${rules.name} ${key}: embedded number ${digits}`);
    });
  });
}
