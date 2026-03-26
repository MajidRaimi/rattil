import re
import tempfile

from faster_whisper import WhisperModel

MODEL_DIR = "/api/model"

_model: WhisperModel | None = None


def load_model() -> None:
    global _model
    _model = WhisperModel(MODEL_DIR, device="cpu", compute_type="float32", cpu_threads=12)


def transcribe(audio_bytes: bytes) -> str:
    if _model is None:
        raise RuntimeError("Model not loaded. Call load_model() first.")

    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        tmp.write(audio_bytes)
        tmp.flush()
        segments, _ = _model.transcribe(tmp.name, language="ar")
        text = " ".join(s.text for s in segments).strip()

    # Remove any Whisper special tokens
    text = re.sub(r"<\|[^|]+\|>", "", text).strip()
    return text
