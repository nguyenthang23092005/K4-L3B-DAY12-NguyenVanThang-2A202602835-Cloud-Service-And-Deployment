FROM python:3.11-slim AS builder

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

WORKDIR /build

COPY requirements.txt .
RUN python -m venv "${VIRTUAL_ENV}" \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt


FROM python:3.11-slim AS runtime

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN useradd --create-home --uid 10001 appuser

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY --chown=appuser:appuser app ./app
COPY --chown=appuser:appuser utils ./utils

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["python", "-c", "import os, urllib.request; urllib.request.urlopen('http://127.0.0.1:' + os.getenv('PORT', '8000') + '/health', timeout=3)"]

CMD ["sh", "-c", "exec uvicorn app.main:app --host 0.0.0.0 --port \"${PORT:-8000}\""]
