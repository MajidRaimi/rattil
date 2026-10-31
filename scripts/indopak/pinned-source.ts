import { invariant } from "./invariant.ts";

export interface PinnedSource {
  url: string;
  sha256: string;
}

export function sha256Hex(bytes: Uint8Array): string {
  return new Bun.CryptoHasher("sha256").update(bytes).digest("hex");
}

export async function fetchPinned(source: PinnedSource): Promise<Uint8Array> {
  const response = await fetch(source.url);
  invariant(response.ok, `HTTP ${response.status} for ${source.url}`);
  const bytes = new Uint8Array(await response.arrayBuffer());
  const actual = sha256Hex(bytes);
  invariant(actual === source.sha256, `sha256 mismatch for ${source.url}: ${actual}`);
  return bytes;
}

export async function readPinnedFile(path: string, sha256: string): Promise<Uint8Array> {
  const bytes = new Uint8Array(await Bun.file(path).arrayBuffer());
  const actual = sha256Hex(bytes);
  invariant(actual === sha256, `sha256 mismatch for ${path}: ${actual}`);
  return bytes;
}
