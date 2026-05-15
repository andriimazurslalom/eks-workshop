import os
import socket
import time

from fastapi import FastAPI, HTTPException
from prometheus_fastapi_instrumentator import Instrumentator

from app.utils import get_app_version, secret_is_configured

app = FastAPI(
    title="Sample Backend App for EKS",
    version=get_app_version(),
    description="A minimal FastAPI service for local development and "
    "future EKS deployment with yaml or helm.",
)

Instrumentator().instrument(app).expose(app, endpoint="/metrics")


SAMPLE_ITEMS = [
    {"id": 1, "name": "alpha", "description": "First sample item"},
    {"id": 2, "name": "beta", "description": "Second sample item"},
    {"id": 3, "name": "gamma", "description": "Third sample item"},
]


def get_runtime_details() -> dict[str, str]:
    hostname = socket.gethostname()

    try:
        ip_address = socket.gethostbyname(hostname)
    except socket.gaierror:
        ip_address = "unknown"

    return {
        "hostname": hostname,
        "ip_address": ip_address,
        "app_version": get_app_version(),
    }


@app.get("/")
def read_root() -> dict[str, str]:
    return {
        "message": "Sample FastAPI app is running",
        "docs": "/docs",
    }


@app.get("/health")
def healthcheck() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/whoami")
def whoami() -> dict[str, str]:
    return get_runtime_details()


@app.get("/api/v1/items")
def list_items() -> dict[str, list[dict[str, object]]]:
    return {"items": SAMPLE_ITEMS}


@app.get("/api/v1/items/{item_id}")
def get_item(item_id: int) -> dict[str, object]:
    for item in SAMPLE_ITEMS:
        if item["id"] == item_id:
            return item

    raise HTTPException(status_code=404, detail=f"Item {item_id} not found")


def get_runtime_config() -> dict[str, object]:
    return {
        "app_env": os.getenv("APP_ENV", "unknown"),
        "log_level": os.getenv("LOG_LEVEL", "unknown"),
        "feature_greeting": os.getenv("FEATURE_GREETING", "false").lower() == "true",
        "external_api_base_url": os.getenv("EXTERNAL_API_BASE_URL", "unknown"),
        "database_configured": secret_is_configured("DATABASE_URL_SECRET_NAME"),
        "jwt_secret_configured": secret_is_configured("JWT_SECRET_NAME"),
        "third_party_api_key_configured": secret_is_configured(
            "THIRD_PARTY_API_KEY_SECRET_NAME"
        ),
        "app_version": get_app_version(),
    }


@app.get("/config")
def read_config() -> dict[str, object]:
    return get_runtime_config()


@app.get("/burn-cpu")
def burn_cpu(seconds: int = 5) -> dict[str, object]:
    end_time = time.time() + seconds
    value = 0

    while time.time() < end_time:
        value += sum(i * i for i in range(1000))

    return {
        "message": "CPU burn completed",
        "seconds": seconds,
        "value": value,
    }
