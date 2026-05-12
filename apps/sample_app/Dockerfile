FROM public.ecr.aws/docker/library/python:3.12-slim

WORKDIR /app

ARG APP_VERSION=0.1.0
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8000
ENV APP_VERSION=${APP_VERSION}

COPY pyproject.toml ./
COPY app ./app

RUN python -m pip install --upgrade pip \
    && python -m pip install .

EXPOSE 8000

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT}"]
