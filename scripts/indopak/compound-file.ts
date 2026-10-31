import { defined, invariant } from "./invariant.ts";

const SIGNATURE = [0xd0, 0xcf, 0x11, 0xe0, 0xa1, 0xb1, 0x1a, 0xe1];
const END_OF_CHAIN = 0xfffffffe;
const FREE_SECTOR = 0xffffffff;
const HEADER_DIFAT_ENTRIES = 109;
const DIRECTORY_ENTRY_SIZE = 128;
const STREAM_OBJECT = 2;

interface CompoundLayout {
  bytes: Uint8Array;
  view: DataView;
  sectorSize: number;
  fat: number[];
  miniStreamCutoff: number;
}

function sectorOffset(layout: Pick<CompoundLayout, "sectorSize">, sector: number): number {
  return (sector + 1) * layout.sectorSize;
}

function readSectorWords(layout: Pick<CompoundLayout, "view" | "sectorSize">, sector: number): number[] {
  const start = sectorOffset(layout, sector);
  return Array.from({ length: layout.sectorSize / 4 }, (_, index) => layout.view.getUint32(start + index * 4, true));
}

function readFatSectorIds(layout: Pick<CompoundLayout, "view" | "sectorSize">): number[] {
  const { view } = layout;
  const ids = Array.from({ length: HEADER_DIFAT_ENTRIES }, (_, index) => view.getUint32(0x4c + index * 4, true));
  let difatSector = view.getUint32(0x44, true);
  while (difatSector !== END_OF_CHAIN && difatSector !== FREE_SECTOR) {
    const words = readSectorWords(layout, difatSector);
    ids.push(...words.slice(0, -1));
    difatSector = defined(words.at(-1), "cfb: empty DIFAT sector");
  }
  return ids.filter((id) => id !== FREE_SECTOR);
}

function readChain(layout: CompoundLayout, firstSector: number): Uint8Array {
  const parts: Uint8Array[] = [];
  const visited = new Set<number>();
  for (let sector = firstSector; sector !== END_OF_CHAIN; sector = defined(layout.fat[sector], "cfb: broken chain")) {
    invariant(!visited.has(sector), "cfb: cyclic sector chain");
    visited.add(sector);
    const start = sectorOffset(layout, sector);
    parts.push(layout.bytes.subarray(start, start + layout.sectorSize));
  }
  return Buffer.concat(parts);
}

function openLayout(bytes: Uint8Array): CompoundLayout {
  invariant(
    SIGNATURE.every((byte, index) => bytes[index] === byte),
    "cfb: not an OLE compound file",
  );
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const sectorSize = 1 << view.getUint16(0x1e, true);
  const partial = { view, sectorSize };
  const fat = readFatSectorIds(partial).flatMap((sector) => readSectorWords(partial, sector));
  return { bytes, view, sectorSize, fat, miniStreamCutoff: view.getUint32(0x38, true) };
}

export function readCompoundStream(bytes: Uint8Array, streamName: string): Uint8Array {
  const layout = openLayout(bytes);
  const directory = readChain(layout, layout.view.getUint32(0x30, true));
  const directoryView = new DataView(directory.buffer, directory.byteOffset, directory.byteLength);
  for (let offset = 0; offset + DIRECTORY_ENTRY_SIZE <= directory.byteLength; offset += DIRECTORY_ENTRY_SIZE) {
    const nameBytes = directoryView.getUint16(offset + 0x40, true);
    if (nameBytes < 2) {
      continue;
    }
    const name = Buffer.from(directory.subarray(offset, offset + nameBytes - 2)).toString("utf16le");
    if (name !== streamName || directory[offset + 0x42] !== STREAM_OBJECT) {
      continue;
    }
    const size = directoryView.getUint32(offset + 0x78, true);
    invariant(size >= layout.miniStreamCutoff, `cfb: ${streamName} is a mini stream, which is not supported`);
    return readChain(layout, directoryView.getUint32(offset + 0x74, true)).subarray(0, size);
  }
  throw new Error(`cfb: stream not found: ${streamName}`);
}
