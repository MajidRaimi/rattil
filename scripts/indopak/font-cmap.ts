import { invariant } from "./invariant.ts";

const UNICODE_PLATFORM = 0;
const WINDOWS_PLATFORM = 3;
const WINDOWS_UNICODE_BMP = 1;
const WINDOWS_UNICODE_FULL = 10;

function findTable(view: DataView, tag: string): number {
  const tableCount = view.getUint16(4);
  for (let index = 0; index < tableCount; index++) {
    const record = 12 + index * 16;
    const recordTag = String.fromCharCode(
      view.getUint8(record),
      view.getUint8(record + 1),
      view.getUint8(record + 2),
      view.getUint8(record + 3),
    );
    if (recordTag === tag) {
      return view.getUint32(record + 8);
    }
  }
  throw new Error(`font: table not found: ${tag}`);
}

function readFormat4(view: DataView, offset: number, codePoints: Set<number>): void {
  const segmentCount = view.getUint16(offset + 6) / 2;
  const endCodes = offset + 14;
  const startCodes = endCodes + segmentCount * 2 + 2;
  const deltas = startCodes + segmentCount * 2;
  const rangeOffsets = deltas + segmentCount * 2;
  for (let segment = 0; segment < segmentCount; segment++) {
    const start = view.getUint16(startCodes + segment * 2);
    const end = view.getUint16(endCodes + segment * 2);
    const delta = view.getUint16(deltas + segment * 2);
    const rangeOffsetPosition = rangeOffsets + segment * 2;
    const rangeOffset = view.getUint16(rangeOffsetPosition);
    for (let codePoint = start; codePoint <= end && codePoint !== 0xffff; codePoint++) {
      const glyph =
        rangeOffset === 0
          ? (codePoint + delta) & 0xffff
          : view.getUint16(rangeOffsetPosition + rangeOffset + (codePoint - start) * 2);
      if (glyph !== 0) {
        codePoints.add(codePoint);
      }
    }
  }
}

function readFormat12(view: DataView, offset: number, codePoints: Set<number>): void {
  const groupCount = view.getUint32(offset + 12);
  for (let group = 0; group < groupCount; group++) {
    const record = offset + 16 + group * 12;
    const start = view.getUint32(record);
    const end = view.getUint32(record + 4);
    const startGlyph = view.getUint32(record + 8);
    for (let codePoint = start; codePoint <= end; codePoint++) {
      if (startGlyph + (codePoint - start) !== 0) {
        codePoints.add(codePoint);
      }
    }
  }
}

export function readCmapCodePoints(fontBytes: Uint8Array): ReadonlySet<number> {
  const view = new DataView(fontBytes.buffer, fontBytes.byteOffset, fontBytes.byteLength);
  const cmap = findTable(view, "cmap");
  const subtableCount = view.getUint16(cmap + 2);
  const codePoints = new Set<number>();
  for (let index = 0; index < subtableCount; index++) {
    const record = cmap + 4 + index * 8;
    const platform = view.getUint16(record);
    const encoding = view.getUint16(record + 2);
    const isUnicode =
      platform === UNICODE_PLATFORM ||
      (platform === WINDOWS_PLATFORM && (encoding === WINDOWS_UNICODE_BMP || encoding === WINDOWS_UNICODE_FULL));
    if (!isUnicode) {
      continue;
    }
    const subtable = cmap + view.getUint32(record + 4);
    const format = view.getUint16(subtable);
    if (format === 4) {
      readFormat4(view, subtable, codePoints);
    } else if (format === 12) {
      readFormat12(view, subtable, codePoints);
    }
  }
  invariant(codePoints.size > 0, "font: no Unicode cmap subtable");
  return codePoints;
}

export function missingCodePoints(text: string, cmap: ReadonlySet<number>, allowed: ReadonlySet<string>): string[] {
  const missing = new Set<string>();
  for (const character of text) {
    if (!allowed.has(character) && !cmap.has(character.codePointAt(0) ?? 0)) {
      missing.add(`U+${(character.codePointAt(0) ?? 0).toString(16).toUpperCase().padStart(4, "0")}`);
    }
  }
  return [...missing];
}
