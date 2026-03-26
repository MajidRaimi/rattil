# Stage 1: Convert model (needs torch + transformers)
FROM python:3.12-slim AS converter

RUN pip install --no-cache-dir faster-whisper torch transformers

RUN ct2-transformers-converter --model deepdml/whisper-small-ar-quran-mix-norm --output_dir /model --quantization int8

# Stage 2: Runtime (slim, no torch)
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg curl && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /api

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

COPY app/ app/

# Copy converted model from builder
COPY --from=converter /model /api/model

EXPOSE 8000

CMD ["uv", "run", "fastapi", "run", "app/main.py", "--host", "0.0.0.0", "--port", "8000"]
