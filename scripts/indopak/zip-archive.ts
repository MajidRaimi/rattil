import { inflateRawSync } from "node:zlib";
import { invariant } from "./invariant.ts";

const END_OF_CENTRAL_DIRECTORY = 0x06054b50;
const CENTRAL_DIRECTORY_ENTRY = 0x02014b50;
const LOCAL_FILE_HEADER = 0x04034b50;
const STORED = 0;
const DEFLATED = 8;

function findEndOfCentralDirectory(view: DataView): number {
  for (let offset = view.byteLength - 22; offset >= 0; offset--) {
    if (view.getUint32(offset, true) === END_OF_CENTRAL_DIRECTORY) {
      return offset;
    }
  }
  throw new Error("zip: end of central directory not found");
}

export function extractZipEntry(archive: Uint8Array, entryName: string): Uint8Array {
  const view = new DataView(archive.buffer, archive.byteOffset, archive.byteLength);
  const end = findEndOfCentralDirectory(view);
  const entryCount = view.getUint16(end + 10, true);
  let cursor = view.getUint32(end + 16, true);
  const decoder = new TextDecoder();
  for (let index = 0; index < entryCount; index++) {
    invariant(view.getUint32(cursor, true) === CENTRAL_DIRECTORY_ENTRY, "zip: bad central directory entry");
    const method = view.getUint16(cursor + 10, true);
    const compressedSize = view.getUint32(cursor + 20, true);
    const size = view.getUint32(cursor + 24, true);
    const nameLength = view.getUint16(cursor + 28, true);
    const extraLength = view.getUint16(cursor + 30, true);
    const commentLength = view.getUint16(cursor + 32, true);
    const localHeader = view.getUint32(cursor + 42, true);
    const name = decoder.decode(archive.subarray(cursor + 46, cursor + 46 + nameLength));
    cursor += 46 + nameLength + extraLength + commentLength;
    if (name !== entryName) {
      continue;
    }
    invariant(view.getUint32(localHeader, true) === LOCAL_FILE_HEADER, "zip: bad local header");
    const dataStart =
      localHeader + 30 + view.getUint16(localHeader + 26, true) + view.getUint16(localHeader + 28, true);
    const compressed = archive.subarray(dataStart, dataStart + compressedSize);
    invariant(method === STORED || method === DEFLATED, `zip: unsupported method ${method}`);
    const data = method === STORED ? compressed : new Uint8Array(inflateRawSync(compressed));
    invariant(data.byteLength === size, `zip: size mismatch for ${entryName}`);
    return data;
  }
  throw new Error(`zip: entry not found: ${entryName}`);
}
