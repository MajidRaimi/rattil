import json
from pathlib import Path

from kashida_core import REPO, TATWEEL_ADVANCE, UPEM, dataset, is_muqattaat, ordered_slots

ALLAH = "للّٰه"
ASSET_PATH = REPO / "assets/quran/indopak-digitalkhatt-kashida.json"


def inside_allah(word: str, at: int) -> bool:
    start = word.find(ALLAH)
    while start != -1:
        if start < at < start + len(ALLAH):
            return True
        start = word.find(ALLAH, start + 1)
    return False


def build_words() -> dict[str, list[list[int]]]:
    words: dict[str, list[list[int]]] = {}
    seen: set[str] = set()
    for chapter, surah in enumerate(dataset()["surahs"], start=1):
        for number, verse in enumerate(surah, start=1):
            for index, word in enumerate(verse.split(" ")):
                if is_muqattaat(chapter, number, index) or word in seen:
                    continue
                seen.add(word)
                slots = [c for c in ordered_slots(word, 6) if not inside_allah(word, c.slot.insert_at)]
                if slots:
                    words[word] = [[c.slot.insert_at, c.cap, c.delta] for c in slots]
    return words


def main() -> None:
    payload = {"unitsPerEm": UPEM, "tatweelAdvance": TATWEEL_ADVANCE, "words": build_words()}
    ASSET_PATH.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")))
    print(len(payload["words"]), ASSET_PATH.stat().st_size)


if __name__ == "__main__":
    main()
