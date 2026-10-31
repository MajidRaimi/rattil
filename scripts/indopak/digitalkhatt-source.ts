import { defined } from "./invariant.ts";
import { END_OF_AYAH, NBSP } from "./quran-constants.ts";

const STRING_LITERAL = /'([^'\\]*)'/g;
const PAGE_SEPARATOR = /\n {2}\],?\n/;
const TITLE_PREFIX = "\u0633\u064F\u0648\u0631\u064E\u0629\u064F ";
const BASMALA_LINE = /^\u0628\u0650\u0633\u0652\u0645\u0650 [^\u06DD]*\u06DD$/;

export const WAW_FATHA = "\u0648\u064E";
export const SAJDA_REMOVAL_KEY = "22:77";

export const IDGHAM_SHADDA_FIXES: ReadonlyMap<string, number> = new Map([
  ["2:41", 16],
  ["2:231", 25],
  ["3:24", 9],
  ["33:44", 4],
]);

export type SourcePages = readonly (readonly string[])[];

export function stringLiterals(text: string): string[] {
  return [...text.matchAll(STRING_LITERAL)].map((match) => defined(match[1], "string literal"));
}

export function readPages(source: string): string[][] {
  const body = source.slice(source.indexOf("[") + 1, source.lastIndexOf("]"));
  return body
    .split(PAGE_SEPARATOR)
    .map(stringLiterals)
    .filter((page) => page.length > 0);
}

export function isTitleLine(line: string): boolean {
  return line.startsWith(TITLE_PREFIX);
}

export function isBasmalaLine(line: string): boolean {
  return BASMALA_LINE.test(line);
}

export function guardMedallion(text: string): string {
  return text.replaceAll(` ${END_OF_AYAH}`, `${NBSP}${END_OF_AYAH}`);
}
