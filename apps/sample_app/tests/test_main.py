from app.main import app
from fastapi.testclient import TestClient

client = TestClient(app)


def test_root_returns_service_message():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {
        "message": "Sample FastAPI app is running",
        "docs": "/docs",
    }


def test_health_returns_ok():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_list_items_returns_sample_items():
    response = client.get("/api/v1/items")
    assert response.status_code == 200

    body = response.json()
    assert "items" in body
    assert len(body["items"]) == 3
    assert body["items"][0]["name"] == "alpha"


def test_get_item_returns_expected_item():
    response = client.get("/api/v1/items/2")
    assert response.status_code == 200
    assert response.json()["name"] == "beta"


def test_get_item_returns_404_for_unknown_item():
    response = client.get("/api/v1/items/999")
    assert response.status_code == 404
    assert response.json()["detail"] == "Item 999 not found"
