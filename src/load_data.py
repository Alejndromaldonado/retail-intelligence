"""Carga los CSV crudos de Olist en DuckDB (modelo staging)."""
import glob
import os
import duckdb
import pandas as pd

from config import DATA_RAW, DUCKDB_PATH

# Mapeo de nombres de archivo CSV -> nombre de tabla
CSV_TABLE_MAP = {
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_customers_dataset.csv": "customers",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "olist_geolocation_dataset.csv": "geolocation",
    "product_category_name_translation.csv": "category_translation",
}


def load_raw_to_duckdb():
    con = duckdb.connect(DUCKDB_PATH)
    for csv_name, table_name in CSV_TABLE_MAP.items():
        path = DATA_RAW / csv_name
        if not path.exists():
            print(f"[SKIP] No encontrado: {path}")
            continue
        con.execute(f"CREATE OR REPLACE TABLE {table_name} AS SELECT * FROM read_csv_auto('{path}')")
        n = con.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
        print(f"[OK] {table_name}: {n} filas")
    con.close()
    print(f"Base de datos guardada en: {DUCKDB_PATH}")


if __name__ == "__main__":
    load_raw_to_duckdb()
