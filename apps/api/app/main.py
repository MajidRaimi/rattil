from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.responses import HTMLResponse, PlainTextResponse

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


@app.get("/ping", response_class=PlainTextResponse)
async def ping():
    return "pong"


@app.get("/test", response_class=HTMLResponse)
async def test_page():
    return """<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>Tasmi' Test</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#0D0D0D;color:#F5F5F5;font-family:-apple-system,system-ui,sans-serif;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:24px}
.container{max-width:480px;width:100%;text-align:center}
h1{font-size:28px;font-weight:700;color:#D4A843;margin-bottom:8px}
.subtitle{font-size:13px;color:#707070;margin-bottom:40px}
.controls{display:flex;flex-direction:column;gap:12px;margin-bottom:32px}
.btn{display:flex;align-items:center;justify-content:center;gap:8px;padding:14px 24px;border-radius:14px;border:none;font-size:14px;font-weight:600;cursor:pointer;transition:all .2s}
.btn-record{background:#D4A843;color:#0D0D0D}
.btn-record.recording{background:#CF6679;animation:pulse 1.5s infinite}
.btn-upload{background:#1A1A1A;color:#F5F5F5;border:1px solid #2A2A2A}
.btn-upload:hover{border-color:#D4A843}
.btn-submit{background:#F5F5F5;color:#0D0D0D}
.btn-submit:disabled{opacity:.3;cursor:not-allowed}
.btn:active{transform:scale(.97)}
@keyframes pulse{0%,100%{opacity:1}50%{opacity:.7}}
input[type=file]{display:none}
.audio-preview{margin:16px 0}
audio{width:100%;border-radius:8px;height:40px}
.result{background:#1A1A1A;border:1px solid #2A2A2A;border-radius:16px;padding:32px 24px;margin-top:24px;display:none}
.result.show{display:block}
.result-text{font-size:28px;line-height:2;direction:rtl;color:#F5F5F5}
.result-label{font-size:11px;color:#707070;margin-bottom:12px;text-transform:uppercase;letter-spacing:1px}
.error{color:#CF6679;font-size:13px;margin-top:16px;display:none}
.error.show{display:block}
.loading{display:none;margin-top:24px}
.loading.show{display:block}
.spinner{width:32px;height:32px;border:3px solid #2A2A2A;border-top-color:#D4A843;border-radius:50%;animation:spin .8s linear infinite;margin:0 auto 12px}
@keyframes spin{to{transform:rotate(360deg)}}
.loading-text{font-size:13px;color:#707070}
.divider{width:48px;height:1px;background:#2A2A2A;margin:24px auto}
.info{font-size:11px;color:#707070;margin-top:32px}
</style>
</head>
<body>
<div class="container">
  <h1>تسميع</h1>
  <p class="subtitle">Test the Quran transcription model</p>

  <div class="controls">
    <button class="btn btn-record" id="recordBtn" onclick="toggleRecord()">
      <span id="recordIcon">&#9679;</span>
      <span id="recordLabel">Start Recording</span>
    </button>

    <label class="btn btn-upload" for="fileInput">
      Upload Audio File
    </label>
    <input type="file" id="fileInput" accept="audio/*" onchange="onFileSelect(event)"/>
  </div>

  <div class="audio-preview" id="audioPreview" style="display:none">
    <audio id="audioPlayer" controls></audio>
    <div style="margin-top:12px">
      <button class="btn btn-submit" id="submitBtn" onclick="submitAudio()">
        Transcribe
      </button>
    </div>
  </div>

  <div class="loading" id="loading">
    <div class="spinner"></div>
    <p class="loading-text">Transcribing...</p>
  </div>

  <div class="result" id="result">
    <p class="result-label">Transcription</p>
    <p class="result-text" id="resultText"></p>
  </div>

  <p class="error" id="error"></p>

  <p class="info">Supports MP3, WAV, M4A. Model: tarteel-ai/whisper-base-ar-quran</p>
</div>

<script>
let mediaRecorder = null;
let audioChunks = [];
let audioBlob = null;
let selectedFile = null;

function toggleRecord() {
  if (mediaRecorder && mediaRecorder.state === 'recording') {
    mediaRecorder.stop();
    return;
  }
  audioChunks = [];
  selectedFile = null;
  navigator.mediaDevices.getUserMedia({ audio: true }).then(stream => {
    mediaRecorder = new MediaRecorder(stream);
    mediaRecorder.ondataavailable = e => audioChunks.push(e.data);
    mediaRecorder.onstop = () => {
      stream.getTracks().forEach(t => t.stop());
      audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
      showPreview(URL.createObjectURL(audioBlob));
      setRecordingState(false);
    };
    mediaRecorder.start();
    setRecordingState(true);
  }).catch(err => {
    showError('Microphone access denied');
  });
}

function setRecordingState(recording) {
  const btn = document.getElementById('recordBtn');
  const label = document.getElementById('recordLabel');
  if (recording) {
    btn.classList.add('recording');
    label.textContent = 'Stop Recording';
  } else {
    btn.classList.remove('recording');
    label.textContent = 'Start Recording';
  }
}

function onFileSelect(e) {
  const file = e.target.files[0];
  if (!file) return;
  selectedFile = file;
  audioBlob = null;
  showPreview(URL.createObjectURL(file));
}

function showPreview(url) {
  document.getElementById('audioPreview').style.display = 'block';
  document.getElementById('audioPlayer').src = url;
  document.getElementById('result').classList.remove('show');
  document.getElementById('error').classList.remove('show');
}

async function submitAudio() {
  const formData = new FormData();
  if (selectedFile) {
    formData.append('audio', selectedFile);
  } else if (audioBlob) {
    formData.append('audio', audioBlob, 'recording.webm');
  } else {
    showError('No audio to transcribe');
    return;
  }

  document.getElementById('loading').classList.add('show');
  document.getElementById('result').classList.remove('show');
  document.getElementById('error').classList.remove('show');
  document.getElementById('submitBtn').disabled = true;

  try {
    const res = await fetch('/tasmi/transcribe', {
      method: 'POST',
      body: formData,
    });
    if (!res.ok) {
      const err = await res.json();
      throw new Error(err.detail || 'Transcription failed');
    }
    const data = await res.json();
    document.getElementById('resultText').textContent = data.text;
    document.getElementById('result').classList.add('show');
  } catch (err) {
    showError(err.message);
  } finally {
    document.getElementById('loading').classList.remove('show');
    document.getElementById('submitBtn').disabled = false;
  }
}

function showError(msg) {
  const el = document.getElementById('error');
  el.textContent = msg;
  el.classList.add('show');
}
</script>
</body>
</html>"""
