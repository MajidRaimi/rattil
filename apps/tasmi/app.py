import modal

MODEL_ID = "naazimsnh02/whisper-large-v3-turbo-ar-quran"

image = (
    modal.Image.debian_slim(python_version="3.12")
    .apt_install("ffmpeg")
    .pip_install(
        "torch",
        "transformers",
        "librosa",
        "fastapi[standard]",
        "python-multipart",
    )
    .run_commands(
        f'python -c "'
        f"from transformers import WhisperProcessor, WhisperForConditionalGeneration; "
        f"WhisperProcessor.from_pretrained('{MODEL_ID}'); "
        f"WhisperForConditionalGeneration.from_pretrained('{MODEL_ID}')"
        f'"'
    )
)

app = modal.App("rattil-tasmi", image=image)


@app.cls(gpu="A10G", min_containers=1)
class Tasmi:
    @modal.enter()
    def load_model(self):
        import torch
        from transformers import WhisperForConditionalGeneration, WhisperProcessor

        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.processor = WhisperProcessor.from_pretrained(MODEL_ID)
        self.model = WhisperForConditionalGeneration.from_pretrained(MODEL_ID).to(
            self.device
        )
        self.model.eval()

    @modal.method()
    def transcribe(self, audio_bytes: bytes) -> str:
        import io
        import re
        import subprocess
        import tempfile

        import librosa
        import torch

        try:
            waveform, _ = librosa.load(io.BytesIO(audio_bytes), sr=16_000, mono=True)
        except Exception:
            with tempfile.NamedTemporaryFile(suffix=".input", delete=False) as tmp_in:
                tmp_in.write(audio_bytes)
                tmp_in.flush()
                with tempfile.NamedTemporaryFile(
                    suffix=".wav", delete=False
                ) as tmp_out:
                    subprocess.run(
                        [
                            "ffmpeg", "-y", "-i", tmp_in.name,
                            "-ar", "16000", "-ac", "1", "-f", "wav", tmp_out.name,
                        ],
                        capture_output=True,
                    )
                    waveform, _ = librosa.load(tmp_out.name, sr=16_000, mono=True)

        input_features = self.processor(
            waveform, sampling_rate=16_000, return_tensors="pt"
        ).input_features.to(self.device)

        with torch.no_grad():
            predicted_ids = self.model.generate(input_features)

        transcription = self.processor.batch_decode(
            predicted_ids, skip_special_tokens=True
        )[0].strip()

        transcription = re.sub(r"<\|[^|]+\|>", "", transcription).strip()
        return transcription


@app.function()
@modal.asgi_app()
def api():
    import fastapi
    from fastapi import UploadFile, File, HTTPException, WebSocket, WebSocketDisconnect

    web_app = fastapi.FastAPI()

    @web_app.post("/transcribe")
    async def transcribe_endpoint(audio: UploadFile = File(...)):
        if audio.content_type and not audio.content_type.startswith("audio/"):
            raise HTTPException(status_code=400, detail="File must be an audio file")

        audio_bytes = await audio.read()
        if not audio_bytes:
            raise HTTPException(status_code=400, detail="Empty audio file")

        tasmi = Tasmi()
        text = tasmi.transcribe.remote(audio_bytes)
        return {"text": text}

    @web_app.websocket("/ws")
    async def websocket_transcribe(websocket: WebSocket):
        await websocket.accept()
        tasmi = Tasmi()
        try:
            while True:
                # Receive audio bytes from client
                audio_bytes = await websocket.receive_bytes()
                # Transcribe on GPU
                text = tasmi.transcribe.remote(audio_bytes)
                # Send back result
                await websocket.send_json({"text": text})
        except WebSocketDisconnect:
            pass

    @web_app.get("/health")
    async def health():
        return {"status": "ok"}

    return web_app
