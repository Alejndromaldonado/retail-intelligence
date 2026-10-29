"""Configuración compartida del proyecto."""
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_RAW = BASE_DIR / "data" / "raw"
DATA_PROCESSED = BASE_DIR / "data" / "processed"
SQL_DIR = BASE_DIR / "sql"
MODELS_DIR = BASE_DIR / "models"

DUCKDB_PATH = os.getenv("DUCKDB_PATH", str(DATA_PROCESSED / "retail.duckdb"))
DATABASE_URL = os.getenv("DATABASE_URL", "")
