from fastapi import APIRouter, UploadFile, File, HTTPException
from pydantic import BaseModel

from app.services.whisper_service import transcribe

router = APIRouter(prefix="/tasmi", tags=["tasmi"])


class TranscriptionResponse(BaseModel):
    text: str


@router.post("/transcribe", response_model=TranscriptionResponse)
async def transcribe_audio(audio: UploadFile = File(...)):
    if audio.content_type and not audio.content_type.startswith("audio/"):
        raise HTTPException(status_code=400, detail="File must be an audio file")

    audio_bytes = await audio.read()
    if not audio_bytes:
        raise HTTPException(status_code=400, detail="Empty audio file")

    text = transcribe(audio_bytes)
    return TranscriptionResponse(text=text)
