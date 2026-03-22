from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.routers import tasmi
from app.services import whisper_service


@asynccontextmanager
async def lifespan(app: FastAPI):
    whisper_service.load_model()
    yield


app = FastAPI(
    title="Rattil API",
    version="0.1.0",
    lifespan=lifespan,
)

app.include_router(tasmi.router)


@app.get("/health")
async def health():
    return {"status": "ok"}
