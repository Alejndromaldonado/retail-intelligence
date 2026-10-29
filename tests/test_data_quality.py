"""Tests básicos de calidad de datos."""
import duckdb
import os

DB_PATH = os.path.join("data", "processed", "retail.duckdb")


def test_orders_not_empty():
    if not os.path.exists(DB_PATH):
        # Skip si aún no se cargaron los datos
        return
    con = duckdb.connect(DB_PATH, read_only=True)
    n = con.execute("SELECT COUNT(*) FROM orders").fetchone()[0]
    con.close()
    assert n > 0, "La tabla orders está vacía"


def test_no_null_order_id():
    if not os.path.exists(DB_PATH):
        return
    con = duckdb.connect(DB_PATH, read_only=True)
    n = con.execute("SELECT COUNT(*) FROM orders WHERE order_id IS NULL").fetchone()[0]
    con.close()
    assert n == 0, "Hay order_id nulos"
