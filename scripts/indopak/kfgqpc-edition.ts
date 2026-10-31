import { defined, invariant } from "./invariant.ts";
import { CGJ, fromArabicIndicDigits, HAFS_VERSE_COUNTS, NBSP, RLO, TAKHALLUS, verseKey } from "./quran-constants.ts";
import { groupBySurah, type IndoPakTextBundle, type VerseMap } from "./text-bundle.ts";

export const KFGQPC_ARCHIVE_SOURCE = {
  url: "https://fonts.qurancomplex.gov.sa/wp-content/uploads/2022/11/HafsNastaleeq-Ver10.zip",
  sha256: "56543ae78f1792b6b8911ba57dd70fb542a311ac0339b1f85563ff446d021442",
};

export const KFGQPC_DOC_ENTRY = "HafsNastaleeq Ver10.doc";
export const KFGQPC_DOC_SHA256 = "c095cd87afe571a27466c06284819b678f8ef97cafa85bc526de54511f8ac653";

const SOURCE_DESCRIPTION =
  "KFGQPC Hafs Nastaleeq text, file \"HafsNastaleeq Ver10.doc\" in https://fonts.qurancomplex.gov.sa/wp-content/uploads/2022/11/HafsNastaleeq-Ver10.zip (zip sha256 56543ae78f1792b6b8911ba57dd70fb542a311ac0339b1f85563ff446d021442), shipped as published. Display normalisation only: whitespace collapsed, NBSP before each ayah number, CGJ between U+064B and U+06E3 in 2:249 3:34 9:66 18:74 27:52 29:35 43:28 59:7.";

const SURAH_HEADER_PREFIX = "\u0633\u064F\u0648\u0652\u0631\u064E\u0629\u064F";
const BASMALA_LINE_END = "\u0600";
const VERSE_END = /\s*([\u0660-\u0669]+)([\uFD30-\uFDFF]*)/g;
const UNGUARDED_TAIL = /\s([\u0660-\u0669]+[\uFD30-\uFDFF]*)$/;
const WHITESPACE_RUN = /\s+/g;
const TANWEEN_SMALL_LOW_SEEN = "\u064B\u06E3";
const SURAHS_WITHOUT_OPENING_BASMALA = new Set([1, 9]);
const NO_SAJDA_KEY = "22:77";
const HAFS_SAJDA_KEYS = [
  "7:206",
  "13:15",
  "16:50",
  "17:109",
  "19:58",
  "22:18",
  "25:60",
  "27:26",
  "32:15",
  "38:24",
  "41:38",
  "53:62",
  "84:21",
  "96:19",
];

export const KFGQPC_CGJ_FIXES: ReadonlyMap<string, string> = new Map([
  ["2:249", "\u063A\u064F\u0631\u0652\u0641\u064E\u0629\u064B\u06E3"],
  ["3:34", "\u0630\u064F\u0631\u0651\u0650\u064A\u0651\u064E\u0629\u064B\u06E3"],
  ["9:66", "\u0637\u064E\u0627\u0653\u0626\u0650\u0641\u064E\u0629\u064B\u06E3"],
  ["18:74", "\u0632\u064E\u0643\u0650\u064A\u0651\u064E\u0629\u064B\u06E3"],
  ["27:52", "\u062E\u064E\u0627\u0648\u0650\u064A\u064E\u0629\u064B\u06E3"],
  ["29:35", "\u0627\u0670\u064A\u064E\u0629\u064B\u06E3"],
  ["43:28", "\u0643\u064E\u0644\u0650\u0645\u064E\u0629\u064B\u06E3"],
  ["59:7", "\u062F\u064F\u0648\u0652\u0644\u064E\u0629\u064B\u06E3"],
]);

interface SurahParagraphs {
  header: string;
  basmala: string | undefined;
  body: string[];
}

function collapseWhitespace(text: string): string {
  return text.replace(WHITESPACE_RUN, " ").trim();
}

function splitSurahs(paragraphs: string[]): SurahParagraphs[] {
  const lines = paragraphs.filter((line) => line.trim() !== "");
  const start = lines.findIndex((line) => line.startsWith(SURAH_HEADER_PREFIX));
  invariant(start >= 0, "no surah header found");
  const surahs: SurahParagraphs[] = [];
  for (const line of lines.slice(start)) {
    if (line.startsWith(SURAH_HEADER_PREFIX)) {
      surahs.push({ header: collapseWhitespace(line), basmala: undefined, body: [] });
      continue;
    }
    const current = defined(surahs.at(-1), "text before the first surah header");
    if (current.body.length === 0 && current.basmala === undefined && line.trimEnd().endsWith(BASMALA_LINE_END)) {
      current.basmala = collapseWhitespace(line);
    } else {
      current.body.push(line);
    }
  }
  invariant(surahs.length === HAFS_VERSE_COUNTS.length, `${surahs.length} surah headers`);
  return surahs;
}

function splitVerses(surah: SurahParagraphs, number: number, verses: VerseMap): void {
  const body = surah.body.join("");
  let cursor = 0;
  let expected = 1;
  for (const match of body.matchAll(VERSE_END)) {
    const end = defined(match.index, "match index") + match[0].length;
    const ayah = fromArabicIndicDigits(defined(match[1], "ayah digits"));
    invariant(ayah === expected, `surah ${number}: embedded number ${ayah}, expected ${expected}`);
    verses.set(verseKey(number, ayah), collapseWhitespace(body.slice(cursor, end)));
    cursor = end;
    expected++;
  }
  invariant(body.slice(cursor).trim() === "", `surah ${number}: text after the last verse`);
  invariant(expected - 1 === HAFS_VERSE_COUNTS[number - 1], `surah ${number}: ${expected - 1} verses`);
}

function openingBasmala(surahs: SurahParagraphs[]): string {
  const forms = new Set<string>();
  surahs.forEach((surah, index) => {
    const number = index + 1;
    const expectsBasmala = !SURAHS_WITHOUT_OPENING_BASMALA.has(number);
    invariant((surah.basmala !== undefined) === expectsBasmala, `surah ${number}: unexpected basmala presence`);
    if (surah.basmala !== undefined) {
      forms.add(surah.basmala);
    }
  });
  invariant(forms.size === 1, `${forms.size} distinct basmala lines`);
  const basmala = defined([...forms][0], "basmala");
  invariant(basmala.endsWith(` ${BASMALA_LINE_END}`), "basmala does not end with a spaced U+0600");
  return `${basmala.slice(0, -2)}${NBSP}${BASMALA_LINE_END}`;
}

function applyCgjFixes(verses: VerseMap): void {
  for (const [key, word] of KFGQPC_CGJ_FIXES) {
    const text = defined(verses.get(key), key);
    const words = text.split(" ");
    invariant(words.filter((candidate) => candidate === word).length === 1, `${key}: expected ${word} once`);
    invariant(word.endsWith(TANWEEN_SMALL_LOW_SEEN), `${key}: ${word} does not end with U+064B U+06E3`);
    const fixed = word.replace(TANWEEN_SMALL_LOW_SEEN, `\u064B${CGJ}\u06E3`);
    verses.set(key, words.map((candidate) => (candidate === word ? fixed : candidate)).join(" "));
  }
}

function tailMarks(text: string): string {
  return /[\u0660-\u0669]+([\uFD30-\uFDFF]*)$/.exec(text)?.[1] ?? "";
}

function assertNoSajdaAt2277(verses: VerseMap): void {
  const sajdaMarks = new Set(HAFS_SAJDA_KEYS.map((key) => tailMarks(defined(verses.get(key), key))));
  invariant(!sajdaMarks.has(""), "a Hafs sajda verse has no sajda mark");
  const carriers = [...verses].filter(([, text]) => [...sajdaMarks].some((mark) => text.includes(mark)));
  invariant(
    carriers.length === HAFS_SAJDA_KEYS.length && carriers.every(([key]) => HAFS_SAJDA_KEYS.includes(key)),
    `sajda marks found outside the Hafs sajda verses: ${carriers.map(([key]) => key).join(" ")}`,
  );
  invariant(!carriers.some(([key]) => key === NO_SAJDA_KEY), `${NO_SAJDA_KEY} carries a sajda mark`);
}

function guardTail(key: string, text: string): string {
  const cleaned = text.replaceAll(RLO, "").replaceAll(TAKHALLUS, "");
  invariant(!cleaned.includes(NBSP), `${key}: source already contains NBSP`);
  invariant(UNGUARDED_TAIL.test(cleaned), `${key}: ayah number is not space separated`);
  return cleaned.replace(UNGUARDED_TAIL, `${NBSP}$1`);
}

export function buildKfgqpcBundle(paragraphs: string[]): IndoPakTextBundle {
  const surahs = splitSurahs(paragraphs);
  const verses: VerseMap = new Map();
  surahs.forEach((surah, index) => splitVerses(surah, index + 1, verses));
  assertNoSajdaAt2277(verses);
  applyCgjFixes(verses);
  for (const [key, text] of verses) {
    verses.set(key, guardTail(key, text));
  }
  return {
    source: SOURCE_DESCRIPTION,
    basmala: openingBasmala(surahs),
    titles: surahs.map((surah) => surah.header),
    surahs: groupBySurah(verses),
  };
}
