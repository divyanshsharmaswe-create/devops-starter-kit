import os

os.environ["DATABASE_URL"] = "sqlite:///./test.db"

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402

from app.db import Base, engine  # noqa: E402
from app.main import app  # noqa: E402


@pytest.fixture()
def client():
    Base.metadata.drop_all(engine)
    with TestClient(app) as c:
        yield c
    Base.metadata.drop_all(engine)


def test_healthz(client):
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_readyz(client):
    assert client.get("/readyz").json() == {"status": "ready"}


def test_notes_crud(client):
    assert client.get("/api/notes").json() == []
    created = client.post("/api/notes", json={"text": "ship it"})
    assert created.status_code == 201
    assert client.get("/api/notes").json() == [{"id": created.json()["id"], "text": "ship it"}]


def test_note_validation(client):
    assert client.post("/api/notes", json={"text": ""}).status_code == 422


def test_metrics_exposed(client):
    client.get("/healthz")
    body = client.get("/metrics").text
    assert "http_requests_total" in body
    assert 'path="/healthz"' in body
