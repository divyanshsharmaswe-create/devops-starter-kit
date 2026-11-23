.PHONY: install dev test lint fmt up down logs tf-validate gif

install:
	python3.12 -m venv .venv && .venv/bin/pip install -q -r requirements-dev.txt

dev:            ## run the API locally on SQLite (no Docker needed)
	.venv/bin/uvicorn app.main:app --reload --port 8080

test:
	.venv/bin/pytest -q

lint:
	.venv/bin/ruff check . && .venv/bin/ruff format --check .

fmt:
	.venv/bin/ruff check --fix . && .venv/bin/ruff format . && terraform fmt -recursive infra

up:             ## full stack: API + Postgres + Prometheus + Grafana
	docker compose up -d --build && echo "API http://localhost:8080  Grafana http://localhost:3000  Prometheus http://localhost:9090"

down:
	docker compose down -v

logs:
	docker compose logs -f api

tf-validate:
	for d in infra/*/; do (cd $$d && terraform init -backend=false -input=false >/dev/null && terraform validate); done

gif:
	vhs docs/demo.tape
