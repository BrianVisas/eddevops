from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_endpoint() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_status_endpoint() -> None:
    response = client.get("/status")
    payload = response.json()

    assert response.status_code == 200
    assert payload["service"] == "platform-status-api"
    assert payload["status"] == "running"
    assert "timestamp" in payload
