# Retail Intelligence — E-commerce Analytics End-to-End

Análisis end-to-end sobre el dataset Olist (e-commerce brasileño, ~100k pedidos):
SQL (modelo estrella) + Power BI (dashboard ejecutivo) + ML (predicción de retraso, segmentación RFM) + NLP (sentimiento de reviews).

## 🎯 Preguntas de negocio
1. ¿Cuál es la tendencia de ventas y ticket medio por mes/estado?
2. ¿Qué categorías generan más ingresos y cuáles tienen peor review?
3. ¿Dónde se concentra la logística lenta (retrasos por estado/vendedor)?
4. ¿Qué segmentos de clientes (RFM) aportan el 80% de ingresos (Pareto)?
5. ¿Podemos predecir si un pedido se retrasará antes de enviarlo?
6. ¿Qué dicen los clientes en las reviews negativas (temas recurrentes)?

## 📊 Demo
- Power BI (público): <URL Publish to web>
- Notebook (nbviewer): <URL>

## 🗂️ Estructura
Ver `PLAN_RETAIL_INTELLIGENCE.md` para el detalle completo.

## 🛠️ Stack
Python, DuckDB/PostgreSQL, Power BI, scikit-learn, SHAP, Streamlit

## 📈 Resultados clave
- Revenue total: R$ X
- % pedidos retrasados: Y%
- ROC-AUC del modelo de retraso: Z
- 4 segmentos RFM: Champions (X%), ...

## 🚀 Cómo reproducir
1. Descargar dataset de Kaggle a `data/raw/`
2. `pip install -r requirements.txt`
3. `python src/load_data.py`
4. Abrir `powerbi/retail_intelligence.pbix`
5. Ejecutar notebooks en `notebooks/`

## 📄 Licencia del dataset
CC BY-NC-SA 4.0 (Olist) — https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
