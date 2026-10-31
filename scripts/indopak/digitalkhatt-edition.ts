import { defined, invariant } from "./invariant.ts";
import {
  END_OF_AYAH,
  HAFS_VERSE_COUNTS,
  RLO,
  SAJDA_SIGN,
  TAKHALLUS,
  toArabicIndicDigits,
  verseKey,
} from "./quran-constants.ts";
import { groupBySurah, type IndoPakTextBundle, type VerseMap } from "./text-bundle.ts";
import { buildPrintedPages } from "./digitalkhatt-pages.ts";
import {
  guardMedallion,
  IDGHAM_SHADDA_FIXES,
  isBasmalaLine,
  isTitleLine,
  readPages,
  SAJDA_REMOVAL_KEY,
  stringLiterals,
  WAW_FATHA,
  type SourcePages,
} from "./digitalkhatt-source.ts";

export const DIGITALKHATT_TEXT_SOURCE = {
  url: "https://raw.githubusercontent.com/DigitalKhatt/digitalkhatt-js/78372d7a1e211bbab677cc0304384f278f508657/apps/site-angular/src/app/services/quran_text_indopak_15.ts",
  sha256: "35310a914f08379e370592d5d28ecae6224bba570cda1e97bab093d23f4cd3df",
};

const SOURCE_DESCRIPTION =
  "DigitalKhatt IndoPak 15-line text, DigitalKhatt/digitalkhatt-js@78372d7a1e211bbab677cc0304384f278f508657 apps/site-angular/src/app/services/quran_text_indopak_15.ts (sha256 35310a914f08379e370592d5d28ecae6224bba570cda1e97bab093d23f4cd3df), MIT. Transforms: Hafs numbering in al-Fatiha, U+202E and U+0614 removed, idgham shadda in 2:41 2:231 3:24 33:44, NBSP before U+06DD, no sajda sign at 22:77.";

const VERSE_END = /(?:\u06DD[\u0660-\u0669]+|\u202E[\u0660-\u0669]+\u08E2)\S*/g;
const SHADDA_FATHA_ON_WAW = /\u0648(?:\u064E\u0651|\u0651\u064E)/g;
const TANWEEN = /[\u064B\u064C\u064D]/;
const FATIHA_DISPUTED_NUMBER = `${RLO}\u0666`;

interface SurahLines {
  title: string;
  basmala: string | undefined;
  content: string[];
}

function collectSurahs(pages: SourcePages): SurahLines[] {
  const surahs: SurahLines[] = [];
  for (const line of pages.flat()) {
    if (isTitleLine(line)) {
      surahs.push({ title: line, basmala: undefined, content: [] });
      continue;
    }
    const current = defined(surahs.at(-1), "text before the first surah title");
    if (isBasmalaLine(line)) {
      current.basmala = line;
    } else {
      current.content.push(line);
    }
  }
  return surahs;
}

function splitVerses(contentLines: string[], surah: number): string[] {
  const text = contentLines.join(" ");
  const verses: string[] = [];
  let start = 0;
  for (const match of text.matchAll(VERSE_END)) {
    const end = defined(match.index, "match index") + match[0].length;
    verses.push(text.slice(start, end).trim());
    start = end;
  }
  invariant(text.slice(start).trim() === "", `surah ${surah}: text after the last verse`);
  return verses;
}

function hafsFatiha(surah: SurahLines, hanafiVerses: string[]): string[] {
  invariant(hanafiVerses.length === 7, `al-Fatiha: ${hanafiVerses.length} source verses`);
  const merged = [
    defined(surah.basmala, "al-Fatiha basmala"),
    ...hanafiVerses.slice(0, 5),
    `${hanafiVerses[5]} ${hanafiVerses[6]}`,
  ];
  return merged.map((text, index) => {
    const cleaned = text.replace(FATIHA_DISPUTED_NUMBER, "");
    const tailStart = cleaned.lastIndexOf(END_OF_AYAH);
    invariant(tailStart >= 0, `1:${index + 1}: no end of ayah`);
    const marks = cleaned.slice(tailStart + 1).replace(/[\u0660-\u0669]/g, "");
    return `${cleaned.slice(0, tailStart)}${END_OF_AYAH}${toArabicIndicDigits(index + 1)}${marks}`;
  });
}

function splitSource(pages: SourcePages): VerseMap {
  const surahs = collectSurahs(pages);
  invariant(surahs.length === HAFS_VERSE_COUNTS.length, `${surahs.length} surah titles`);
  const verses: VerseMap = new Map();
  surahs.forEach((surah, index) => {
    const number = index + 1;
    const split = splitVerses(surah.content, number);
    const ayat = number === 1 ? hafsFatiha(surah, split) : split;
    invariant(ayat.length === HAFS_VERSE_COUNTS[index], `surah ${number}: ${ayat.length} verses`);
    ayat.forEach((text, ayahIndex) => verses.set(verseKey(number, ayahIndex + 1), text));
  });
  return verses;
}

function dominantShaddaOrder(verses: VerseMap): string {
  const counts = new Map<string, number>();
  for (const text of verses.values()) {
    for (const [form] of text.matchAll(SHADDA_FATHA_ON_WAW)) {
      counts.set(form, (counts.get(form) ?? 0) + 1);
    }
  }
  const ranked = [...counts].sort((a, b) => b[1] - a[1]);
  const [first, second] = ranked;
  invariant(first !== undefined && (second === undefined || first[1] > second[1]), "ambiguous shadda order");
  return first[0];
}

function applyIdghamShadda(verses: VerseMap): void {
  const shaddaWaw = dominantShaddaOrder(verses);
  for (const [key, wordIndex] of IDGHAM_SHADDA_FIXES) {
    const words = defined(verses.get(key), key).split(" ");
    const word = defined(words[wordIndex], `${key} word ${wordIndex}`);
    invariant(word.startsWith(WAW_FATHA), `${key}: word ${wordIndex} does not start with waw fatha`);
    invariant(TANWEEN.test(defined(words[wordIndex - 1], key)), `${key}: previous word has no tanween`);
    words[wordIndex] = shaddaWaw + word.slice(WAW_FATHA.length);
    verses.set(key, words.join(" "));
  }
}

function removeSajdaAt2277(verses: VerseMap): void {
  const text = defined(verses.get(SAJDA_REMOVAL_KEY), SAJDA_REMOVAL_KEY);
  invariant(text.split(SAJDA_SIGN).length === 2, `${SAJDA_REMOVAL_KEY}: expected exactly one sajda sign`);
  verses.set(SAJDA_REMOVAL_KEY, text.replace(SAJDA_SIGN, ""));
}

function headers(source: string): { titles: string[]; basmala: string } {
  const lines = stringLiterals(source);
  const titles = lines.filter(isTitleLine);
  const basmalas = new Set(lines.filter(isBasmalaLine));
  invariant(titles.length === HAFS_VERSE_COUNTS.length, `${titles.length} titles`);
  invariant(basmalas.size === 1, `${basmalas.size} distinct basmala lines`);
  return { titles, basmala: guardMedallion(defined([...basmalas][0], "basmala")) };
}

export function buildDigitalKhattBundle(source: string): IndoPakTextBundle {
  const pages = readPages(source);
  const verses = splitSource(pages);
  applyIdghamShadda(verses);
  removeSajdaAt2277(verses);
  for (const [key, text] of verses) {
    verses.set(key, guardMedallion(text.replaceAll(TAKHALLUS, "")));
    invariant(text.split(END_OF_AYAH).length === 2, `${key}: expected exactly one end of ayah`);
  }
  const bundle = { source: SOURCE_DESCRIPTION, ...headers(source), surahs: groupBySurah(verses) };
  return { ...bundle, pages: buildPrintedPages(pages, bundle) };
}
