FROM python:3.11-slim

WORKDIR /app/

COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/
COPY ./app /app/

RUN uv sync --frozen

ENV PATH="/app/.venv/bin:$PATH"
