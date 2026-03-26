from typing import AsyncGenerator

import edge_tts
from fastapi import APIRouter, Query
from fastapi.responses import StreamingResponse

router = APIRouter(prefix="/tts", tags=["tts"])

VOICE_MAP = {
    "ar": "ar-SA-HamedNeural",
    "en": "en-US-GuyNeural",
    "bn": "bn-BD-PradeepNeural",
    "ur": "ur-PK-AsadNeural",
    "ru": "ru-RU-DmitryNeural",
    "ku": "ar-SA-HamedNeural",
}


async def _stream_audio(text: str, voice: str) -> AsyncGenerator[bytes, None]:
    communicate = edge_tts.Communicate(text, voice)
    async for chunk in communicate.stream():
        if chunk["type"] == "audio":
            yield chunk["data"]


@router.get("/speak")
async def speak(
    text: str = Query(...),
    lang: str = Query("ar", max_length=5),
):
    voice = VOICE_MAP.get(lang, VOICE_MAP["en"])
    return StreamingResponse(
        _stream_audio(text, voice),
        media_type="audio/mpeg",
        headers={"Content-Disposition": "inline; filename=tts.mp3"},
    )
