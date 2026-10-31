import json
import re
import unicodedata
from dataclasses import dataclass, field
from functools import lru_cache
from pathlib import Path

import uharfbuzz as hb
from fontTools.ttLib import TTFont

REPO = Path(__file__).resolve().parents[2] / "apps/mobile"
FONT_PATH = REPO / "assets/fonts/DigitalKhattIndoPak.ttf"
DATA_PATH = REPO / "assets/quran/indopak-digitalkhatt.json"
UCD_PATH = Path(__file__).with_name("ucd") / "ArabicShaping.txt"

UPEM = 1000
LINE_WIDTH_EM = 20.7
TATWEEL = "ـ"
WORD_JOINER = "‏ "
CENTRE_RATIO = 0.7

SEEN_GROUP = frozenset("سشصض")
HEH_FINALS = frozenset("هة")
TALL_FINALS = frozenset("الكطظدذ")
EXTRA_MARK_LIKE = frozenset("͏")
BLOCKERS = frozenset("ۥۦ")
ELONGATION_SUFFIX = re.compile(r"\.-?\d+_-?\d+_\d+$")


def _load_joining_types() -> dict[int, str]:
    table: dict[int, str] = {}
    for raw in UCD_PATH.read_text().splitlines():
        line = raw.split("#")[0].strip()
        if not line:
            continue
        parts = [p.strip() for p in line.split(";")]
        table[int(parts[0], 16)] = parts[2]
    return table


JOINING = _load_joining_types()


def joining_type(ch: str) -> str:
    found = JOINING.get(ord(ch))
    if found:
        return found
    return "T" if unicodedata.category(ch) in ("Mn", "Me", "Cf") else "U"


def is_mark(ch: str) -> bool:
    return unicodedata.category(ch) == "Mn" or ch in EXTRA_MARK_LIKE


_blob = hb.Blob.from_file_path(str(FONT_PATH))
_face = hb.Face(_blob)
HB_FONT = hb.Font(_face)
TT = TTFont(str(FONT_PATH))
GLYPH_ORDER = TT.getGlyphOrder()
GDEF_CLASSES = TT["GDEF"].table.GlyphClassDef.classDefs
TATWEEL_GID = TT.getGlyphID("tatweel")
TATWEEL_ADVANCE = TT["hmtx"]["tatweel"][0]
SPACE_ADVANCE = TT["hmtx"][TT.getBestCmap()[0x20]][0]


def _load_curs() -> list[tuple[dict[str, tuple[int, int]], dict[str, tuple[int, int]]]]:
    gpos = TT["GPOS"].table
    tables = []
    for record in gpos.FeatureList.FeatureRecord:
        if record.FeatureTag != "curs":
            continue
        for index in record.Feature.LookupListIndex:
            for sub in gpos.LookupList.Lookup[index].SubTable:
                sub = sub.ExtSubTable if sub.LookupType == 9 else sub
                if sub.LookupType != 3:
                    continue
                entry: dict[str, tuple[int, int]] = {}
                exit_: dict[str, tuple[int, int]] = {}
                for name, rec in zip(sub.Coverage.glyphs, sub.EntryExitRecord):
                    if rec.EntryAnchor:
                        entry[name] = (rec.EntryAnchor.XCoordinate, rec.EntryAnchor.YCoordinate)
                    if rec.ExitAnchor:
                        exit_[name] = (rec.ExitAnchor.XCoordinate, rec.ExitAnchor.YCoordinate)
                tables.append((entry, exit_))
    return tables


CURS = _load_curs()


@dataclass(frozen=True)
class Glyph:
    name: str
    cluster: int
    advance: int
    x: int
    y: int


@lru_cache(maxsize=400_000)
def shape(text: str) -> tuple[Glyph, ...]:
    buf = hb.Buffer()
    buf.add_str(text)
    buf.guess_segment_properties()
    buf.cluster_level = hb.BufferClusterLevel.MONOTONE_CHARACTERS
    hb.shape(HB_FONT, buf, {})
    glyphs = []
    pen = 0
    for info, pos in zip(buf.glyph_infos, buf.glyph_positions):
        glyphs.append(
            Glyph(
                GLYPH_ORDER[info.codepoint],
                info.cluster,
                pos.x_advance,
                pen + pos.x_offset,
                pos.y_offset,
            )
        )
        pen += pos.x_advance
    return tuple(glyphs)


def advance(text: str) -> int:
    return sum(g.advance for g in shape(text))


@dataclass(frozen=True)
class Letter:
    index: int
    char: str
    end: int


def letters_of(word: str) -> list[Letter]:
    found: list[Letter] = []
    for i, ch in enumerate(word):
        if is_mark(ch):
            continue
        found.append(Letter(i, ch, i + 1))
    result = []
    for k, letter in enumerate(found):
        end = found[k + 1].index if k + 1 < len(found) else len(word)
        result.append(Letter(letter.index, letter.char, end))
    return result


def joins_left(letter: str) -> bool:
    return joining_type(letter) in ("D", "C")


def joins_right(letter: str) -> bool:
    return joining_type(letter) in ("D", "R", "C")


@dataclass(frozen=True)
class Slot:
    insert_at: int
    left: str
    right: str
    right_is_final: bool
    left_is_initial: bool
    connection_index: int


def raw_slots(word: str) -> list[Slot]:
    letters = letters_of(word)
    slots = []
    connection = 0
    for k in range(len(letters) - 1):
        left, right = letters[k], letters[k + 1]
        if left.char in BLOCKERS or right.char in BLOCKERS:
            continue
        if unicodedata.category(left.char) not in ("Lo", "Lm") or unicodedata.category(right.char) not in ("Lo", "Lm"):
            continue
        if not (joins_left(left.char) and joins_right(right.char)):
            continue
        after = letters[k + 2] if k + 2 < len(letters) else None
        right_is_final = not (joins_left(right.char) and after is not None and joins_right(after.char))
        before = letters[k - 1] if k > 0 else None
        left_is_initial = not (before is not None and joins_left(before.char) and joins_right(left.char))
        slots.append(Slot(left.end, left.char, right.char, right_is_final, left_is_initial, connection))
        connection += 1
    return slots


def insert(word: str, counts: dict[int, int]) -> str:
    out = []
    for i, ch in enumerate(word):
        if i in counts:
            out.append(TATWEEL * counts[i])
        out.append(ch)
    if len(word) in counts:
        out.append(TATWEEL * counts[len(word)])
    return "".join(out)


def _index_map(word: str, counts: dict[int, int]) -> list[int]:
    mapping = []
    for i in range(len(word) + 1):
        mapping.extend([-1] * counts.get(i, 0))
        if i < len(word):
            mapping.append(i)
    return mapping


def normalised(name: str) -> str:
    return ELONGATION_SUFFIX.sub("", name)


def _is_mark_glyph(name: str) -> bool:
    return GDEF_CLASSES.get(name) == 3


@dataclass
class Verdict:
    ok: bool
    reason: str
    delta: int
    changed_elongation: bool = False


def _mark_offsets(glyph_list: list[tuple[str, int, int, int, int]]) -> list[tuple[int, int, int, str]]:
    result = []
    base = None
    for name, source, gx, gy, adv in glyph_list:
        if _is_mark_glyph(name):
            if base is None:
                result.append((source, 99999, 99999, name))
            else:
                result.append((source, gx - base[1], gy - base[2], normalised(base[0])))
        else:
            base = (name, gx, gy)
    return result


def _curs_connected(left: tuple[str, int, int, int], right: tuple[str, int, int, int]) -> bool:
    lname, lx, ly, _ = left
    rname, rx, ry, _ = right
    for entry, exit_ in CURS:
        if lname in exit_ and rname in entry:
            ex = exit_[lname]
            en = entry[rname]
            return (lx + ex[0], ly + ex[1]) == (rx + en[0], ry + en[1])
    return False


def validate(word: str, counts: dict[int, int]) -> Verdict:
    plain = shape(word)
    stretched_text = insert(word, counts)
    stretched = shape(stretched_text)
    mapping = _index_map(word, counts)
    if any(g.name == ".notdef" or "dotted" in g.name for g in stretched):
        return Verdict(False, "notdef", 0)
    def pen_positions(glyphs: tuple[Glyph, ...]) -> list[tuple[str, int, int, int, int]]:
        return [(g.name, g.cluster, g.x, g.y, g.advance) for g in glyphs]
    plain_items = pen_positions(plain)
    stretched_items = pen_positions(stretched)
    plain_logical = [(n, c, x, y, a) for n, c, x, y, a in plain_items][::-1]
    stretched_logical = [(n, c, x, y, a) for n, c, x, y, a in stretched_items][::-1]
    inserted = [it for it in stretched_logical if mapping[it[1]] == -1]
    total_inserted = sum(counts.values())
    if len(inserted) != total_inserted or any(it[0] != "tatweel" for it in inserted):
        return Verdict(False, "tatweel-not-plain", 0)
    kept = [(n, mapping[c], x, y, a) for n, c, x, y, a in stretched_logical if mapping[c] != -1]
    plain_seq = [(normalised(n), c) for n, c, *_ in plain_logical]
    kept_seq = [(normalised(n), c) for n, c, *_ in kept]
    if plain_seq != kept_seq:
        return Verdict(False, "glyph-change", 0)
    changed_elongation = [n for n, *_ in plain_logical] != [n for n, *_ in kept]
    plain_marks = _mark_offsets([(n, c, x, y, a) for n, c, x, y, a in plain_logical])
    kept_marks = _mark_offsets(kept)
    for pm, km in zip(plain_marks, kept_marks):
        if pm[0] != km[0] or pm[3] != km[3]:
            return Verdict(False, "mark-base-change", 0)
        if not changed_elongation and (pm[1], pm[2]) != (km[1], km[2]):
            return Verdict(False, "mark-moved", 0)
        if abs(pm[2] - km[2]) > 60:
            return Verdict(False, "mark-moved-vertically", 0)
    bases = [it for it in stretched_logical if not _is_mark_glyph(it[0])]
    for k, item in enumerate(bases):
        if mapping[item[1]] != -1:
            continue
        prev_item = bases[k - 1] if k > 0 else None
        next_item = bases[k + 1] if k + 1 < len(bases) else None
        if prev_item is None or next_item is None:
            return Verdict(False, "tatweel-at-edge", 0)
        left = (prev_item[0], prev_item[2], prev_item[3], prev_item[4])
        mid = (item[0], item[2], item[3], item[4])
        right = (next_item[0], next_item[2], next_item[3], next_item[4])
        if not _curs_connected(left, mid) or not _curs_connected(mid, right):
            return Verdict(False, "curs-gap", 0)
    delta = sum(g.advance for g in stretched) - sum(g.advance for g in plain)
    return Verdict(True, "ok", delta, changed_elongation)


PRIORITY_NAMES = {
    1: "after-seen-sad",
    2: "before-final-heh",
    3: "medial-medial",
    4: "before-final-tall",
    5: "before-final-round",
    6: "before-final-reh-waw",
    7: "after-initial",
}
REH_WAW_FINALS = frozenset("\u0631\u0632\u0648")
SHORT_WORD_PENALTY = 2


def priority(slot: Slot, base_letters: int) -> int:
    if slot.left in SEEN_GROUP:
        rank = 1
    elif slot.right_is_final and slot.right in HEH_FINALS:
        rank = 2
    elif not slot.right_is_final and not slot.left_is_initial:
        rank = 3
    elif slot.right_is_final and slot.right in TALL_FINALS:
        rank = 4
    elif slot.right_is_final and slot.right in REH_WAW_FINALS:
        rank = 6
    elif slot.right_is_final:
        rank = 5
    else:
        rank = 7
    if base_letters <= 2:
        rank += SHORT_WORD_PENALTY
    return rank


@dataclass
class Candidate:
    slot: Slot
    rank: int
    delta: int
    cap: int


@lru_cache(maxsize=200_000)
def word_candidates(word: str, cap: int = 3) -> tuple[Candidate, ...]:
    letters = [l for l in letters_of(word) if unicodedata.category(l.char) in ("Lo", "Lm")]
    found = []
    for slot in raw_slots(word):
        allowed = 0
        delta = 0
        for n in range(1, cap + 1):
            verdict = validate(word, {slot.insert_at: n})
            if not verdict.ok:
                break
            allowed = n
            if n == 1:
                delta = verdict.delta
        rank = priority(slot, len(letters))
        allowed = min(allowed, SHORT_WORD_CAPS.get(len(letters), cap), RANK_CAPS.get(rank, LOW_RANK_CAP))
        if allowed:
            found.append(Candidate(slot, rank, delta, allowed))
    return tuple(found)


def best_candidate(word: str, cap: int = 3) -> Candidate | None:
    options = word_candidates(word, cap)
    if not options:
        return None
    return min(options, key=lambda c: (c.rank, -c.slot.connection_index))


@lru_cache(maxsize=1)
def dataset() -> dict:
    return json.loads(DATA_PATH.read_text())


def verse_words(chapter: int, number: int) -> list[str]:
    return dataset()["surahs"][chapter - 1][number - 1].split(" ")


MUQATTAAT_CHAPTERS = frozenset(
    (2, 3, 7, 10, 11, 12, 13, 14, 15, 19, 20, 26, 27, 28, 29, 30, 31, 32, 36, 38, 40, 41, 42, 43, 44, 45, 46, 50, 68)
)
MUQATTAAT_EXTRA = frozenset({(42, 2)})


def is_muqattaat(chapter: int, number: int, word_index: int) -> bool:
    if word_index != 0:
        return False
    return (number == 1 and chapter in MUQATTAAT_CHAPTERS) or (chapter, number) in MUQATTAAT_EXTRA


@dataclass
class LineModel:
    page: int
    index: int
    words: list[str]
    ends_surah: bool
    locked: list[bool] = field(default_factory=list)
    centred: bool = False
    natural: int = 0


def page_lines(page: int) -> list[LineModel]:
    data = dataset()
    lines = []
    for index, line in enumerate(data["pages"][page - 1]):
        if "words" not in line:
            continue
        words: list[str] = []
        locked: list[bool] = []
        for chapter, number, start, end in line["words"]:
            words.extend(verse_words(chapter, number)[start:end])
            locked.extend(is_muqattaat(chapter, number, i) for i in range(start, end))
        last = line["words"][-1]
        surah = data["surahs"][last[0] - 1]
        ends = last[1] == len(surah) and last[3] == len(verse_words(last[0], last[1]))
        model = LineModel(page, index, words, ends, locked)
        model.natural = line_natural(words)
        width = LINE_WIDTH_EM * UPEM
        model.centred = page <= 2 or (ends and model.natural < width * CENTRE_RATIO)
        lines.append(model)
    return lines


def line_natural(words: list[str]) -> int:
    return sum(advance(w) for w in words) + (len(words) - 1) * SPACE_ADVANCE


@dataclass
class LineFit:
    words: list[str]
    counts: list[dict[int, int]]
    gap: float
    scale: float
    tatweels: int
    natural: int
    stretched: int


def plain_fit(model: LineModel) -> LineFit:
    width = LINE_WIDTH_EM * UPEM
    natural = model.natural
    spaces = len(model.words) - 1
    if model.centred or spaces == 0 or natural >= width:
        scale = min(1.0, width / natural) if natural else 1.0
        return LineFit(model.words, [{} for _ in model.words], 0.0, scale, 0, natural, natural)
    gap = (width - natural) / spaces
    return LineFit(model.words, [{} for _ in model.words], gap, 1.0, 0, natural, natural)


DEFAULT_SCHEDULE: tuple[tuple[int, int, int], ...] = (
    (3, 1, 0),
    (5, 1, 0),
    (3, 2, 0),
    (7, 1, 0),
    (5, 2, 0),
    (9, 1, 0),
    (7, 2, 0),
    (9, 2, 0),
    (3, 3, 0),
    (5, 1, 1),
    (5, 3, 0),
    (5, 2, 1),
    (9, 3, 0),
    (3, 4, 0),
    (5, 4, 0),
    (5, 3, 1),
    (4, 5, 0),
    (4, 6, 0),
)
SHORT_WORD_CAPS = {1: 0, 2: 2, 3: 3}
RANK_CAPS = {1: 6, 2: 6, 3: 5, 4: 5, 5: 3, 6: 2, 7: 2}
LOW_RANK_CAP = 2
SECONDARY_MAX_RANK = 5
SECONDARY_MIN_LETTERS = 4


@dataclass
class Settings:
    cap: int = 6
    min_gap_extra: float = 0.1
    schedule: tuple[tuple[int, int, int], ...] = DEFAULT_SCHEDULE
    long_kashida_from: int = 5
    long_kashida_min_gap: float = 0.3


def ordered_slots(word: str, cap: int) -> list[Candidate]:
    options = sorted(word_candidates(word, cap), key=lambda c: (c.rank, -c.slot.connection_index))
    if not options:
        return []
    primary = options[0]
    letters = sum(1 for l in letters_of(word) if unicodedata.category(l.char) in ("Lo", "Lm"))
    chosen = [primary]
    if letters >= SECONDARY_MIN_LETTERS:
        for cand in options[1:]:
            if cand.rank > SECONDARY_MAX_RANK:
                continue
            if abs(cand.slot.connection_index - primary.slot.connection_index) < 2:
                continue
            if validate(word, {primary.slot.insert_at: 1, cand.slot.insert_at: 1}).ok:
                chosen.append(cand)
                break
    return chosen


def kashida_fit(model: LineModel, settings: Settings = Settings()) -> LineFit:
    width = LINE_WIDTH_EM * UPEM
    base = plain_fit(model)
    spaces = len(model.words) - 1
    if model.centred or spaces == 0 or model.natural >= width:
        return base
    budget = width - model.natural - settings.min_gap_extra * UPEM * spaces
    slots = [[] if lock else ordered_slots(w, settings.cap) for w, lock in zip(model.words, model.locked)]
    order = sorted(
        (wi for wi, c in enumerate(slots) if c),
        key=lambda wi: (slots[wi][0].rank, -len(model.words[wi]), wi),
    )
    counts: list[dict[int, int]] = [{} for _ in model.words]
    widths = [advance(w) for w in model.words]
    used = 0
    for max_rank, target, which in settings.schedule:
        if target >= settings.long_kashida_from:
            residual = (budget - used) / spaces / UPEM + settings.min_gap_extra
            if residual < settings.long_kashida_min_gap:
                continue
        for wi in order:
            if which >= len(slots[wi]):
                continue
            cand = slots[wi][which]
            if cand.rank > max_rank or target > cand.cap:
                continue
            current = counts[wi].get(cand.slot.insert_at, 0)
            if current >= target:
                continue
            trial = dict(counts[wi])
            trial[cand.slot.insert_at] = current + 1
            new_width = advance(insert(model.words[wi], trial))
            gain = new_width - widths[wi]
            if gain <= 0 or used + gain > budget:
                continue
            counts[wi] = trial
            used += gain
            widths[wi] = new_width
    stretched = sum(widths) + spaces * SPACE_ADVANCE
    gap = (width - stretched) / spaces
    return LineFit(model.words, counts, gap, 1.0, sum(sum(c.values()) for c in counts), model.natural, stretched)
