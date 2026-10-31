import { readCompoundStream } from "./compound-file.ts";
import { invariant } from "./invariant.ts";

const WORD_IDENT = 0xa5ec;
const WHICH_TABLE_STREAM_FLAG = 0x0200;
const CCP_TEXT_OFFSET = 0x4c;
const FC_CLX_OFFSET = 0x01a2;
const PRC_MARKER = 0x01;
const PCDT_MARKER = 0x02;
const PIECE_DESCRIPTOR_SIZE = 8;
const COMPRESSED_FLAG = 0x40000000;
const FIELD_BEGIN = "\u0013";
const FIELD_SEPARATOR = "\u0014";
const FIELD_END = "\u0015";
const PARAGRAPH_MARKS = /[\r\u000b\u000c\u0007]/g;
const INLINE_OBJECT_MARKS = /[\u0001\u0002\u0008]/g;

interface Piece {
  cpStart: number;
  cpEnd: number;
  fileOffset: number;
  compressed: boolean;
}

function readPieces(table: Uint8Array, clxOffset: number, clxLength: number): Piece[] {
  const view = new DataView(table.buffer, table.byteOffset, table.byteLength);
  let cursor = clxOffset;
  while (table[cursor] === PRC_MARKER) {
    cursor += 3 + view.getInt16(cursor + 1, true);
  }
  invariant(table[cursor] === PCDT_MARKER, "doc: piece table not found");
  invariant(cursor < clxOffset + clxLength, "doc: piece table outside the CLX");
  const plcLength = view.getUint32(cursor + 1, true);
  const plcStart = cursor + 5;
  const count = (plcLength - 4) / (4 + PIECE_DESCRIPTOR_SIZE);
  invariant(Number.isInteger(count), "doc: malformed piece table");
  const descriptors = plcStart + (count + 1) * 4;
  return Array.from({ length: count }, (_, index) => {
    const rawOffset = view.getUint32(descriptors + index * PIECE_DESCRIPTOR_SIZE + 2, true);
    const compressed = (rawOffset & COMPRESSED_FLAG) !== 0;
    const offset = rawOffset & ~COMPRESSED_FLAG;
    return {
      cpStart: view.getUint32(plcStart + index * 4, true),
      cpEnd: view.getUint32(plcStart + (index + 1) * 4, true),
      fileOffset: compressed ? offset / 2 : offset,
      compressed,
    };
  });
}

function decodePiece(document: Uint8Array, piece: Piece, cpLimit: number): string {
  const length = Math.min(piece.cpEnd, cpLimit) - piece.cpStart;
  if (length <= 0) {
    return "";
  }
  if (piece.compressed) {
    return new TextDecoder("windows-1252").decode(document.subarray(piece.fileOffset, piece.fileOffset + length));
  }
  return Buffer.from(document.subarray(piece.fileOffset, piece.fileOffset + length * 2)).toString("utf16le");
}

function keepFieldResults(text: string): string {
  let output = "";
  const stack: boolean[] = [];
  for (const character of text) {
    if (character === FIELD_BEGIN) {
      stack.push(false);
    } else if (character === FIELD_SEPARATOR) {
      stack[stack.length - 1] = true;
    } else if (character === FIELD_END) {
      stack.pop();
    } else if (stack.every(Boolean)) {
      output += character;
    }
  }
  return output;
}

export function extractWordParagraphs(docBytes: Uint8Array): string[] {
  const document = readCompoundStream(docBytes, "WordDocument");
  const view = new DataView(document.buffer, document.byteOffset, document.byteLength);
  invariant(view.getUint16(0, true) === WORD_IDENT, "doc: not a Word 97-2003 document");
  const tableName = view.getUint16(0x0a, true) & WHICH_TABLE_STREAM_FLAG ? "1Table" : "0Table";
  const table = readCompoundStream(docBytes, tableName);
  const mainTextLength = view.getUint32(CCP_TEXT_OFFSET, true);
  const pieces = readPieces(table, view.getUint32(FC_CLX_OFFSET, true), view.getUint32(FC_CLX_OFFSET + 4, true));
  const raw = pieces.map((piece) => decodePiece(document, piece, mainTextLength)).join("");
  invariant(raw.length === mainTextLength, "doc: main text length mismatch");
  return keepFieldResults(raw).replace(INLINE_OBJECT_MARKS, "").split(PARAGRAPH_MARKS);
}
