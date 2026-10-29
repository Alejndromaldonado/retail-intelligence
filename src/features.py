"""Feature engineering para los modelos de ML."""
import pandas as pd
import numpy as np


def build_delay_features(orders_df, items_df, customers_df, sellers_df, products_df):
    """Construye el dataset de features para predecir retraso de entrega."""
    # Merge base
    df = orders_df.merge(items_df, on="order_id", how="inner")
    df = df.merge(customers_df, on="customer_id", how="left")
    df = df.merge(sellers_df, on="seller_id", how="left")
    df = df.merge(products_df, on="product_id", how="left")

    # Target
    df["is_late"] = (
        pd.to_datetime(df["order_delivered_customer_date"])
        > pd.to_datetime(df["order_estimated_delivery_date"])
    ).astype(int)

    # Días de entrega
    df["delivery_days"] = (
        pd.to_datetime(df["order_delivered_customer_date"])
        - pd.to_datetime(df["order_purchase_timestamp"])
    ).dt.days

    # Día de la semana / mes de compra
    df["purchase_dow"] = pd.to_datetime(df["order_purchase_timestamp"]).dt.dayofweek
    df["purchase_month"] = pd.to_datetime(df["order_purchase_timestamp"]).dt.month

    return df


def build_rfm(orders_df, items_df):
    """Construye la tabla RFM por cliente."""
    last_date = pd.to_datetime(orders_df["order_purchase_timestamp"]).max()
    merged = orders_df.merge(items_df, on="order_id")
    delivered = merged[merged["order_status"] == "delivered"].copy()
    delivered["order_purchase_timestamp"] = pd.to_datetime(delivered["order_purchase_timestamp"])
    rfm = (
        delivered.groupby("customer_id")
        .agg(
            recency=("order_purchase_timestamp", lambda x: (last_date - x.max()).days),
            frequency=("order_id", "nunique"),
            monetary=("price", "sum"),
        )
        .reset_index()
    )
    return rfm
