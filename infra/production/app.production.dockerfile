FROM --platform=linux/amd64 python:3.11-slim

WORKDIR /stack-simple/

COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

COPY ../../app /stack-simple/app/
#RUN rm -rf /stack-simple/app/tests
COPY ../../pyproject.toml ../../uv.lock /stack-simple/

RUN uv sync --frozen
ENV PATH="/stack-simple/.venv/bin:$PATH"
ENV POSTGRES_HOST="stack-db.c30iuu6soju5.us-east-1.rds.amazonaws.com"
ENV POSTGRES_PORT=5432
ENV POSTGRES_DB="app"
ENV POSTGRES_USER="app"
ENV POSTGRES_PASSWORD="app"

EXPOSE 8000

CMD ["gunicorn", "app.main:app", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
