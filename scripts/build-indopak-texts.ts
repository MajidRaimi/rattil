import { mkdirSync } from "node:fs";
import { join } from "node:path";
import { parseArgs } from "node:util";
import { buildDigitalKhattBundle, DIGITALKHATT_TEXT_SOURCE } from "./indopak/digitalkhatt-edition.ts";
import { readCmapCodePoints } from "./indopak/font-cmap.ts";
import {
  buildKfgqpcBundle,
  KFGQPC_ARCHIVE_SOURCE,
  KFGQPC_DOC_ENTRY,
  KFGQPC_DOC_SHA256,
} from "./indopak/kfgqpc-edition.ts";
import { invariant } from "./indopak/invariant.ts";
import { fetchPinned, readPinnedFile, sha256Hex, type PinnedSource } from "./indopak/pinned-source.ts";
import { CGJ, NBSP } from "./indopak/quran-constants.ts";
import { flattenBundle, validateBundle, type EditionRules, type IndoPakTextBundle } from "./indopak/text-bundle.ts";
import { extractWordParagraphs } from "./indopak/word-document.ts";
import { extractZipEntry } from "./indopak/zip-archive.ts";

const MOBILE_ASSETS = new URL("../apps/mobile/assets/", import.meta.url).pathname;
const QURAN_ASSETS = join(MOBILE_ASSETS, "quran");

const DIGITALKHATT_FONT = {
  path: join(MOBILE_ASSETS, "fonts/DigitalKhattIndoPak.ttf"),
  sha256: "0e435ecd7e271ed5b2cf6b36ad60f945606d2c4649bc3f13048a75bfd6b40959",
};

const KFGQPC_FONT = {
  path: join(MOBILE_ASSETS, "fonts/HafsNastaleeq-Ver10.otf"),
  sha256: "166b6dd86d76832ccef684a42ec6b0645ad6cc9b78f6041772ea3412138d2a69",
};

const USAGE = `Usage: bun run scripts/build-indopak-texts.ts [--flat-dir <dir>]

Fetches the pinned DigitalKhatt IndoPak text and the pinned KFGQPC Hafs Nastaleeq zip,
checks their sha256, applies the display transforms with asserts and writes
apps/mobile/assets/quran/indopak-digitalkhatt.json and indopak-kfgqpc.json.
--flat-dir also writes each edition as a flat {"s:a": text} map for render checks.`;

interface Edition {
  name: string;
  fileName: string;
  font: { path: string; sha256: string };
  rules: Omit<EditionRules, "name" | "cmap">;
  build: () => Promise<IndoPakTextBundle>;
}

async function fetchText(source: PinnedSource): Promise<string> {
  return new TextDecoder().decode(await fetchPinned(source));
}

async function readKfgqpcParagraphs(): Promise<string[]> {
  const doc = extractZipEntry(await fetchPinned(KFGQPC_ARCHIVE_SOURCE), KFGQPC_DOC_ENTRY);
  invariant(sha256Hex(doc) === KFGQPC_DOC_SHA256, `${KFGQPC_DOC_ENTRY}: sha256 mismatch`);
  return extractWordParagraphs(doc);
}

const EDITIONS: Edition[] = [
  {
    name: "digitalkhatt",
    fileName: "indopak-digitalkhatt.json",
    font: DIGITALKHATT_FONT,
    rules: {
      embeddedNumber: /\u06DD([\u0660-\u0669]+)/,
      guardedTail: /^[^\u06DD]*\u00A0\u06DD[^\u06DD]*$/,
      absentFromFont: new Set([" ", NBSP]),
      printedPages: true,
    },
    build: async () => buildDigitalKhattBundle(await fetchText(DIGITALKHATT_TEXT_SOURCE)),
  },
  {
    name: "kfgqpc",
    fileName: "indopak-kfgqpc.json",
    font: KFGQPC_FONT,
    rules: {
      embeddedNumber: /\u00A0([\u0660-\u0669]+)[\uFD30-\uFDFF]*$/,
      guardedTail: /\u00A0[\u0660-\u0669]+[\uFD30-\uFDFF]*$/,
      absentFromFont: new Set([" ", NBSP, CGJ]),
      printedPages: false,
    },
    build: async () => buildKfgqpcBundle(await readKfgqpcParagraphs()),
  },
];

async function buildEdition(edition: Edition, flatDir: string | undefined): Promise<void> {
  const cmap = readCmapCodePoints(await readPinnedFile(edition.font.path, edition.font.sha256));
  const bundle = await edition.build();
  validateBundle(bundle, { ...edition.rules, name: edition.name, cmap });
  const outputPath = join(QURAN_ASSETS, edition.fileName);
  await Bun.write(outputPath, JSON.stringify(bundle));
  console.log(`${edition.name}: wrote ${outputPath} (${Bun.file(outputPath).size} bytes)`);
  if (flatDir !== undefined) {
    const flatPath = join(flatDir, edition.fileName.replace(".json", "-flat.json"));
    await Bun.write(flatPath, JSON.stringify(flattenBundle(bundle)));
    console.log(`${edition.name}: wrote ${flatPath}`);
  }
}

async function main(): Promise<void> {
  const { values } = parseArgs({
    args: Bun.argv.slice(2),
    options: { "flat-dir": { type: "string" }, help: { type: "boolean" } },
  });
  if (values.help) {
    console.log(USAGE);
    return;
  }
  mkdirSync(QURAN_ASSETS, { recursive: true });
  const flatDir = values["flat-dir"];
  if (flatDir !== undefined) {
    mkdirSync(flatDir, { recursive: true });
  }
  for (const edition of EDITIONS) {
    await buildEdition(edition, flatDir);
  }
}

main().catch((error: unknown) => {
  console.error(error);
  process.exit(1);
});
