# Sample FastAPI App

This is a minimal FastAPI backend application intended to be deployed separately from the Terraform infrastructure in `infra/`.

## Endpoints

- `GET /` returns a simple service message
- `GET /health` returns a health response
- `GET /api/v1/items` returns a sample list of items
- `GET /api/v1/items/{item_id}` returns a single item by ID

## Run locally

```bash
cd apps/sample_app
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Then open `http://127.0.0.1:8000/docs`.
