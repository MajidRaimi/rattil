import io
import re
import subprocess
import tempfile

import librosa
import torch
from transformers import WhisperForConditionalGeneration, WhisperProcessor

MODEL_ID = "tarteel-ai/whisper-base-ar-quran"

_processor: WhisperProcessor | None = None
_model: WhisperForConditionalGeneration | None = None
_device: torch.device | None = None


def load_model() -> None:
    global _processor, _model, _device
    _device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    _processor = WhisperProcessor.from_pretrained(MODEL_ID)
    _model = WhisperForConditionalGeneration.from_pretrained(MODEL_ID).to(_device)
    _model.eval()


def transcribe(audio_bytes: bytes) -> str:
    if _processor is None or _model is None or _device is None:
        raise RuntimeError("Model not loaded. Call load_model() first.")

    # Try librosa directly first; fall back to ffmpeg for unsupported formats (webm, ogg, etc.)
    try:
        waveform, _ = librosa.load(io.BytesIO(audio_bytes), sr=16_000, mono=True)
    except Exception:
        # Convert to WAV via ffmpeg
        with tempfile.NamedTemporaryFile(suffix=".input", delete=False) as tmp_in:
            tmp_in.write(audio_bytes)
            tmp_in.flush()
            with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp_out:
                subprocess.run(
                    ["ffmpeg", "-y", "-i", tmp_in.name, "-ar", "16000", "-ac", "1", "-f", "wav", tmp_out.name],
                    capture_output=True,
                )
                waveform, _ = librosa.load(tmp_out.name, sr=16_000, mono=True)

    input_features = _processor(
        waveform,
        sampling_rate=16_000,
        return_tensors="pt",
    ).input_features.to(_device)

    with torch.no_grad():
        predicted_ids = _model.generate(input_features)

    transcription: str = _processor.batch_decode(
        predicted_ids, skip_special_tokens=True
    )[0].strip()

    # Remove any remaining Whisper special tokens like <|ar|>, <|transcribe|>, etc.
    transcription = re.sub(r"<\|[^|]+\|>", "", transcription).strip()

    return transcription
