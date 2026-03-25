import io
import edge_tts
from fastapi import APIRouter, Query
from fastapi.responses import StreamingResponse

router = APIRouter(prefix="/tts", tags=["tts"])

VOICE_MAP = {
    "ar": "ar-SA-ZariyahNeural",
    "en": "en-US-JennyNeural",
    "bn": "bn-BD-NabanitaNeural",
    "ur": "ur-PK-UzmaNeural",
    "ru": "ru-RU-SvetlanaNeural",
    "ku": "ar-SA-ZariyahNeural",
}


@router.get("/speak")
async def speak(
    text: str = Query(..., max_length=5000),
    lang: str = Query("ar", max_length=5),
):
    voice = VOICE_MAP.get(lang, VOICE_MAP["en"])
    communicate = edge_tts.Communicate(text, voice)

    buffer = io.BytesIO()
    async for chunk in communicate.stream():
        if chunk["type"] == "audio":
            buffer.write(chunk["data"])

    buffer.seek(0)
    return StreamingResponse(
        buffer,
        media_type="audio/mpeg",
        headers={"Content-Disposition": "inline; filename=tts.mp3"},
    )
