export const HAFS_VERSE_COUNTS: readonly number[] = [
  7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77,
  227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55,
  78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36,
  25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6,
];

export const SURAH_COUNT = 114;
export const VERSE_TOTAL = 6236;

export const NBSP = "\u00A0";
export const RLO = "\u202E";
export const TAKHALLUS = "\u0614";
export const CGJ = "\u034F";
export const END_OF_AYAH = "\u06DD";
export const SAJDA_SIGN = "\u08DB";
export const ARABIC_INDIC_DIGITS = "\u0660\u0661\u0662\u0663\u0664\u0665\u0666\u0667\u0668\u0669";

export function toArabicIndicDigits(value: number): string {
  return [...String(value)].map((digit) => ARABIC_INDIC_DIGITS[Number(digit)]).join("");
}

export function fromArabicIndicDigits(digits: string): number {
  return Number([...digits].map((digit) => ARABIC_INDIC_DIGITS.indexOf(digit)).join(""));
}

export function verseKey(surah: number, ayah: number): string {
  return `${surah}:${ayah}`;
}
