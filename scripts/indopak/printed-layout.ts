import { invariant } from "./invariant.ts";
import { SURAH_COUNT, verseKey } from "./quran-constants.ts";

export type WordRange = [surah: number, ayah: number, from: number, to: number];

export type PrintedLine = { title: number } | { basmala: number } | { words: WordRange[] };

export type PrintedPage = PrintedLine[];

export interface VerseWord {
  surah: number;
  ayah: number;
  index: number;
  word: string;
}

export const PRINTED_PAGE_COUNT = 610;
export const SURAHS_WITHOUT_BASMALA_LINE: ReadonlySet<number> = new Set([1, 9]);

const WORD_SEPARATOR = " ";
const OPENING_PAGE_COUNT = 2;
const OPENING_PAGE_LINES = 8;
const FINAL_PAGE_LINES = 10;
const STANDARD_PAGE_LINES = 15;

export function splitVerseWords(text: string): string[] {
  return text.split(WORD_SEPARATOR);
}

export function expectedLineCount(pageNumber: number): number {
  if (pageNumber <= OPENING_PAGE_COUNT) {
    return OPENING_PAGE_LINES;
  }
  return pageNumber === PRINTED_PAGE_COUNT ? FINAL_PAGE_LINES : STANDARD_PAGE_LINES;
}

export function* verseWords(surahs: readonly (readonly string[])[]): Generator<VerseWord> {
  for (const [surahIndex, ayat] of surahs.entries()) {
    for (const [ayahIndex, text] of ayat.entries()) {
      for (const [index, word] of splitVerseWords(text).entries()) {
        yield { surah: surahIndex + 1, ayah: ayahIndex + 1, index, word };
      }
    }
  }
}

function assertLineCounts(pages: readonly PrintedPage[]): void {
  invariant(pages.length === PRINTED_PAGE_COUNT, `printed layout: ${pages.length} pages`);
  pages.forEach((page, pageIndex) => {
    const expected = expectedLineCount(pageIndex + 1);
    invariant(page.length === expected, `printed page ${pageIndex + 1}: ${page.length} lines, expected ${expected}`);
  });
}

function assertHeaders(lines: readonly PrintedLine[]): void {
  let surah = 0;
  let basmalaCount = 0;
  lines.forEach((line, index) => {
    if ("title" in line) {
      surah += 1;
      invariant(line.title === surah, `printed layout: title ${line.title} where ${surah} expected`);
    } else if ("basmala" in line) {
      basmalaCount += 1;
      const previous = lines[index - 1];
      invariant(
        previous !== undefined && "title" in previous && previous.title === line.basmala,
        `printed layout: basmala ${line.basmala} does not follow its title`,
      );
      invariant(!SURAHS_WITHOUT_BASMALA_LINE.has(line.basmala), `printed layout: basmala line for surah ${line.basmala}`);
    }
  });
  invariant(surah === SURAH_COUNT, `printed layout: ${surah} titles`);
  invariant(
    basmalaCount === SURAH_COUNT - SURAHS_WITHOUT_BASMALA_LINE.size,
    `printed layout: ${basmalaCount} basmala lines`,
  );
}

function assertWordCoverage(lines: readonly PrintedLine[], surahs: readonly (readonly string[])[]): void {
  const expected = verseWords(surahs);
  let surah = 0;
  lines.forEach((line) => {
    if ("title" in line) {
      surah = line.title;
      return;
    }
    if (!("words" in line)) {
      return;
    }
    invariant(line.words.length > 0, `printed layout: empty text line in surah ${surah}`);
    for (const [rangeSurah, ayah, from, to] of line.words) {
      const key = verseKey(rangeSurah, ayah);
      invariant(rangeSurah === surah, `printed layout: ${key} under the title of surah ${surah}`);
      invariant(from < to, `printed layout: ${key} empty range ${from}..${to}`);
      for (let index = from; index < to; index += 1) {
        const next = expected.next();
        invariant(next.done !== true, `printed layout: ${key} word ${index} past the last verse`);
        const word = next.value;
        invariant(
          word.surah === rangeSurah && word.ayah === ayah && word.index === index,
          `printed layout: ${key} word ${index} where ${verseKey(word.surah, word.ayah)} word ${word.index} expected`,
        );
      }
    }
  });
  invariant(expected.next().done === true, "printed layout: verse words left uncovered");
}

export function assertPrintedLayout(pages: readonly PrintedPage[], surahs: readonly (readonly string[])[]): void {
  assertLineCounts(pages);
  const lines = pages.flat();
  assertHeaders(lines);
  assertWordCoverage(lines, surahs);
}
