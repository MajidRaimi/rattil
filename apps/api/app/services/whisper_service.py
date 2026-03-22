import io
import re

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

    # librosa handles MP3, WAV, M4A, etc. and resamples to 16kHz
    waveform, _ = librosa.load(io.BytesIO(audio_bytes), sr=16_000, mono=True)

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
