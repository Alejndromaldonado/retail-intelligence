"""Demo interactiva (opcional) del proyecto Retail Intelligence."""
import streamlit as st
import pandas as pd

st.set_page_config(page_title="Retail Intelligence", page_icon="📊", layout="wide")
st.title("📊 Retail Intelligence — E-commerce Analytics")
st.caption("Dataset: Olist Brazilian E-Commerce (~100k pedidos)")

st.markdown(
    """
    ### Secciones
    - **Ventas**: tendencia mensual, top categorías.
    - **Logística**: retrasos por estado.
    - **Clientes**: segmentos RFM.
    - **Reviews**: distribución de scores.

    > Conecta esta app a los CSV/Parquet procesados para hacerla interactiva.
    """
)

uploaded = st.file_uploader("Sube un CSV procesado (opcional)", type=["csv"])
if uploaded is not None:
    df = pd.read_csv(uploaded)
    st.dataframe(df.head(50))
    st.write("Filas:", len(df))
