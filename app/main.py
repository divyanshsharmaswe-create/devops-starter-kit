"""A small FastAPI service with health, readiness and Prometheus metrics endpoints."""

import os
import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest
from pydantic import BaseModel, Field
from sqlalchemy import select, text

from .db import Note, SessionLocal, init_db

APP_VERSION = os.environ.get("APP_VERSION", "dev")

REQUESTS = Counter("http_requests_total", "HTTP requests", ["method", "path", "status"])
LATENCY = Histogram("http_request_duration_seconds", "Request latency", ["method", "path"])


@asynccontextmanager
async def lifespan(_: FastAPI):
    init_db()
    yield


app = FastAPI(title="devops-starter-kit", version=APP_VERSION, lifespan=lifespan)


@app.middleware("http")
async def record_metrics(request: Request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    route = request.scope.get("route")
    path = route.path if route else "unmatched"
    LATENCY.labels(request.method, path).observe(time.perf_counter() - start)
    REQUESTS.labels(request.method, path, str(response.status_code)).inc()
    return response


class NoteIn(BaseModel):
    text: str = Field(min_length=1, max_length=500)


class NoteOut(NoteIn):
    id: int


@app.get("/healthz")
def healthz() -> dict:
    """Liveness: the process is up."""
    return {"status": "ok", "version": APP_VERSION}


@app.get("/readyz")
def readyz() -> dict:
    """Readiness: the database is reachable."""
    try:
        with SessionLocal() as session:
            session.execute(text("SELECT 1"))
    except Exception as exc:  # noqa: BLE001 - any DB error means not ready
        raise HTTPException(status_code=503, detail="database unavailable") from exc
    return {"status": "ready"}


@app.get("/metrics")
def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.get("/api/notes", response_model=list[NoteOut])
def list_notes() -> list[NoteOut]:
    with SessionLocal() as session:
        notes = session.scalars(select(Note).order_by(Note.id)).all()
        return [NoteOut(id=n.id, text=n.text) for n in notes]


@app.post("/api/notes", response_model=NoteOut, status_code=201)
def create_note(note: NoteIn) -> NoteOut:
    with SessionLocal() as session:
        row = Note(text=note.text)
        session.add(row)
        session.commit()
        return NoteOut(id=row.id, text=row.text)
