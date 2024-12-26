FROM --platform=linux/amd64 python:3.11-slim

WORKDIR /stack-simple/

COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

COPY ../../app /stack-simple/app/
#RUN rm -rf /stack-simple/app/tests
COPY ../../pyproject.toml ../../uv.lock /stack-simple/

RUN uv sync --frozen
ENV PATH="/stack-simple/.venv/bin:$PATH"

EXPOSE 8000

CMD ["gunicorn", "app.main:app", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
