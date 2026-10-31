import {
  guardMedallion,
  IDGHAM_SHADDA_FIXES,
  isBasmalaLine,
  isTitleLine,
  SAJDA_REMOVAL_KEY,
  WAW_FATHA,
  type SourcePages,
} from "./digitalkhatt-source.ts";
import { defined, invariant } from "./invariant.ts";
import {
  splitVerseWords,
  verseWords,
  type PrintedLine,
  type PrintedPage,
  type VerseWord,
  type WordRange,
} from "./printed-layout.ts";
import { END_OF_AYAH, NBSP, RLO, SAJDA_SIGN, TAKHALLUS, verseKey } from "./quran-constants.ts";
import type { IndoPakTextBundle } from "./text-bundle.ts";

type SourceLine =
  | { kind: "title"; surah: number }
  | { kind: "basmala"; surah: number }
  | { kind: "text"; surah: number; location: string; words: string[] };

type TextLine = Extract<SourceLine, { kind: "text" }>;

interface SourceEquivalence {
  applies: (word: VerseWord) => boolean;
  normalize: (text: string) => string;
}

type LayoutInputs = Pick<IndoPakTextBundle, "titles" | "basmala" | "surahs">;

const FATIHA = 1;
const ORPHAN_MEDALLION_LINES: readonly string[] = ["472:2"];
const ARABIC_INDIC_DIGIT_RUN = /[٠-٩]+/g;
const LEADING_SHADDA_FATHA_ON_WAW = /^و(?:َّ|َّ)/;

const SOURCE_EQUIVALENCES: readonly SourceEquivalence[] = [
  {
    applies: () => true,
    normalize: (text) => text.replaceAll(TAKHALLUS, "").replaceAll(RLO, ""),
  },
  {
    applies: (word) => word.surah === FATIHA,
    normalize: (text) => text.replace(ARABIC_INDIC_DIGIT_RUN, ""),
  },
  {
    applies: (word) => IDGHAM_SHADDA_FIXES.get(verseKey(word.surah, word.ayah)) === word.index,
    normalize: (text) => text.replace(LEADING_SHADDA_FATHA_ON_WAW, WAW_FATHA),
  },
  {
    applies: (word) => verseKey(word.surah, word.ayah) === SAJDA_REMOVAL_KEY,
    normalize: (text) => text.replaceAll(SAJDA_SIGN, ""),
  },
];

function canonicalWord(text: string, word: VerseWord): string {
  return SOURCE_EQUIVALENCES.filter((rule) => rule.applies(word)).reduce(
    (current, rule) => rule.normalize(current),
    text,
  );
}

function classifyLine(text: string, surah: number, location: string, inputs: LayoutInputs): SourceLine {
  if (isTitleLine(text)) {
    invariant(text === inputs.titles[surah - 1], `${location}: title is not the title of surah ${surah}`);
    return { kind: "title", surah };
  }
  invariant(surah > 0, `${location}: text before the first surah title`);
  if (isBasmalaLine(text) && surah !== FATIHA) {
    invariant(guardMedallion(text) === inputs.basmala, `${location}: basmala differs from the bundle basmala`);
    return { kind: "basmala", surah };
  }
  return { kind: "text", surah, location, words: splitVerseWords(guardMedallion(text)) };
}

function classifyPages(pages: SourcePages, inputs: LayoutInputs): SourceLine[][] {
  let surah = 0;
  return pages.map((page, pageIndex) =>
    page.map((text, lineIndex) => {
      surah += isTitleLine(text) ? 1 : 0;
      return classifyLine(text, surah, `${pageIndex + 1}:${lineIndex + 1}`, inputs);
    }),
  );
}

function reflowOrphanMedallions(lines: readonly SourceLine[]): void {
  const reflowed: string[] = [];
  let previous: TextLine | undefined;
  for (const line of lines) {
    if (line.kind !== "text") {
      previous = undefined;
      continue;
    }
    const first = defined(line.words[0], `${line.location}: empty line`);
    if (first.startsWith(END_OF_AYAH)) {
      const host = defined(previous, `${line.location}: orphan medallion without a preceding text line`);
      const lastIndex = host.words.length - 1;
      host.words[lastIndex] = `${defined(host.words[lastIndex], host.location)}${NBSP}${first}`;
      line.words.shift();
      invariant(line.words.length > 0, `${line.location}: line held only a medallion`);
      reflowed.push(line.location);
    }
    previous = line;
  }
  invariant(
    reflowed.join(" ") === ORPHAN_MEDALLION_LINES.join(" "),
    `orphan medallions at ${reflowed.join(" ")}, expected ${ORPHAN_MEDALLION_LINES.join(" ")}`,
  );
}

function extendRanges(ranges: WordRange[], word: VerseWord): void {
  const last = ranges.at(-1);
  if (last !== undefined && last[0] === word.surah && last[1] === word.ayah && last[3] === word.index) {
    last[3] += 1;
    return;
  }
  ranges.push([word.surah, word.ayah, word.index, word.index + 1]);
}

function alignTextLine(line: TextLine, cursor: Generator<VerseWord>): WordRange[] {
  const ranges: WordRange[] = [];
  for (const sourceWord of line.words) {
    const next = cursor.next();
    invariant(next.done !== true, `${line.location}: source words past the last verse`);
    const word = next.value;
    invariant(
      canonicalWord(word.word, word) === canonicalWord(sourceWord, word),
      `${line.location}: source word ${sourceWord} does not match ${verseKey(word.surah, word.ayah)} word ${word.index} ${word.word}`,
    );
    extendRanges(ranges, word);
  }
  return ranges;
}

function toPrintedLine(line: SourceLine, cursor: Generator<VerseWord>): PrintedLine {
  switch (line.kind) {
    case "title":
      return { title: line.surah };
    case "basmala":
      return { basmala: line.surah };
    case "text":
      return { words: alignTextLine(line, cursor) };
  }
}

export function buildPrintedPages(pages: SourcePages, inputs: LayoutInputs): PrintedPage[] {
  const classified = classifyPages(pages, inputs);
  reflowOrphanMedallions(classified.flat());
  const cursor = verseWords(inputs.surahs);
  const printed = classified.map((page) => page.map((line) => toPrintedLine(line, cursor)));
  invariant(cursor.next().done === true, "printed layout: verse words not placed on any line");
  return printed;
}
