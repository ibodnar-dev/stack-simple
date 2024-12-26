FROM --platform=linux/amd64 python:3.11-slim

WORKDIR /stack-simple/

COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

COPY ./app /stack-simple/app/
COPY ./pyproject.toml ./uv.lock /stack-simple/

RUN uv sync --frozen
ENV PATH="/stack-simple/.venv/bin:$PATH"
