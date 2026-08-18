from datetime import UTC, datetime

from fastapi import FastAPI

app = FastAPI(title="Platform Status API", version="1.0.0")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/status")
def status() -> dict[str, str]:
    return {
        "service": "platform-status-api",
        "status": "running",
        "timestamp": datetime.now(UTC).isoformat(),
    }
