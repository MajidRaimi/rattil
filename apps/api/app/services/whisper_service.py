import re
import tempfile

from faster_whisper import WhisperModel

MODEL_DIR = "/api/model"

_model: WhisperModel | None = None


def load_model() -> None:
    global _model
    _model = WhisperModel(MODEL_DIR, device="cpu", compute_type="int8", cpu_threads=8)


def transcribe(audio_bytes: bytes) -> str:
    if _model is None:
        raise RuntimeError("Model not loaded. Call load_model() first.")

    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        tmp.write(audio_bytes)
        tmp.flush()
        segments, _ = _model.transcribe(
            tmp.name,
            language="ar",
            beam_size=1,
            vad_filter=True,
            vad_parameters=dict(min_silence_duration_ms=500),
        )
        text = " ".join(s.text for s in segments).strip()

    # Remove any Whisper special tokens
    text = re.sub(r"<\|[^|]+\|>", "", text).strip()
    return text
