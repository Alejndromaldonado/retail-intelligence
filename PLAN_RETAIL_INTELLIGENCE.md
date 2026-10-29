# 📊 Retail Intelligence — Plan de Proyecto End-to-End

> **Objetivo:** construir un proyecto de portafolio que demuestre, en un solo caso de negocio, tus skills de **Data Analyst + BI + IA aplicada + Big Data (opcional)**, alineado con tu Master en IA for Business, Big Data y Analytics.  
> **Costo total: $0** (todo con free tiers).  
> **Tiempo estimado:** 3 semanas (5–8 h/semana).  
> **Carpeta de trabajo:** `C:\Proyectos\Retail_Intelligence`

---

## 0. Pitch del proyecto (para tu CV / LinkedIn / portfolio)

> **"Retail Intelligence: análisis end-to-end de e-commerce brasileño"**  
> Pipeline completo sobre ~100k pedidos de Olist: modelado estrella en SQL, dashboard ejecutivo en Power BI, segmentación de clientes (RFM + K-Means), predicción de retraso de entrega con ML y análisis de sentimiento de reviews (NLP). Todo reproducible, con código público y demo interactiva.

**Rol que atrae:** Data Analyst / Business Analyst / BI Developer / Data Scientist junior.  
**Diferenciador:** un solo proyecto demuestra SQL + BI + ML + NLP + ingeniería de datos.

---

## 1. Dataset: Olist Brazilian E-Commerce

**Fuente:** Kaggle — "Brazilian E-Commerce Public Dataset by Olist"  
**URL:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce  
**Licencia:** CC BY-NC-SA 4.0 (citar en README).  
**Tamaño:** ~100k pedidos, 9 tablas CSV, ~120 MB.  
**Periodo:** 2016-09 a 2018-10.

### 1.1 Tablas y uso

| Archivo CSV | Tabla destino | Uso principal |
|---|---|---|
| `olist_orders_dataset.csv` | `orders` | Fact principal (estado, fechas) |
| `olist_order_items_dataset.csv` | `order_items` | Fact de líneas (precio, freight) |
| `olist_order_payments_dataset.csv` | `order_payments` | Fact de pagos |
| `olist_order_reviews_dataset.csv` | `order_reviews` | NLP (comentario + score) |
| `olist_customers_dataset.csv` | `customers` | Dim cliente (ciudad, estado) |
| `olist_products_dataset.csv` | `products` | Dim producto (categoría) |
| `olist_sellers_dataset.csv` | `sellers` | Dim vendedor |
| `olist_geolocation_dataset.csv` | `geolocation` | Dim geografía (lat/lon) |
| `product_category_name_translation.csv` | `category_translation` | Traducción PT→EN |

### 1.2 Preguntas de negocio que responderás

1. ¿Cuál es la tendencia de ventas y ticket medio por mes/estado?
2. ¿Qué categorías generan más ingresos y cuáles tienen peor review?
3. ¿Dónde se concentra la logística lenta (retrasos por estado/vendedor)?
4. ¿Qué segmentos de clientes (RFM) aportan el 80% de ingresos (Pareto)?
5. ¿Podemos predecir si un pedido se retrasará antes de enviarlo?
6. ¿Qué dicen los clientes en las reviews negativas (temas recurrentes)?

---

## 2. Estructura de carpetas del proyecto

Crea esta estructura dentro de `C:\Proyectos\Retail_Intelligence`:

```
Retail_Intelligence/
├── README.md
├── requirements.txt
├── .gitignore
├── .env.example
├── data/
│   ├── raw/                 # CSVs descargados de Kaggle (NO subir a git)
│   └── processed/           # Parquets limpios
├── sql/
│   ├── 01_create_schema.sql
│   ├── 02_load_data.sql     # (o Python)
│   ├── 03_star_model.sql
│   └── queries/
│       ├── q01_sales_trend.sql
│       ├── q02_top_categories.sql
│       ├── q03_delivery_delays.sql
│       ├── q04_rfm_base.sql
│       └── q05_cohorts.sql
├── notebooks/
│   ├── 01_eda.ipynb
│   ├── 02_rfm_segmentation.ipynb
│   ├── 03_delay_prediction.ipynb
│   └── 04_sentiment_analysis.ipynb
├── src/
│   ├── config.py
│   ├── load_data.py         # CSV → DuckDB/Supabase
│   ├── features.py          # Feature engineering
│   └── train.py            # Entrenamiento ML
├── models/
│   └── delay_model.pkl
├── powerbi/
│   ├── retail_intelligence.pbix
│   └── retail_intelligence.pdf   # export estático (backup)
├── app/
│   └── streamlit_app.py     # Demo interactiva (opcional)
├── docs/
│   └── architecture.png
└── tests/
    └── test_data_quality.py
```

### 2.1 `.gitignore` recomendado

```
data/raw/
data/processed/
*.pbix
models/*.pkl
.env
__pycache__/
.ipynb_checkpoints/
```

> ⚠️ Sube el `.pbix` a un release de GitHub o a Drive; no al repo (archivo binario grande). En el README pon el link de descarga.

### 2.2 `requirements.txt`

```
pandas>=2.2
numpy>=1.26
duckdb>=1.0
sqlalchemy>=2.0
scikit-learn>=1.4
shap>=0.45
nltk>=3.8
matplotlib>=3.8
seaborn>=0.13
plotly>=5.20
streamlit>=1.35
joblib>=1.3
jupyter>=1.0
python-dotenv>=1.0
pytest>=8.0
```

Instalar: `pip install -r requirements.txt`

---

## 3. Parte A — SQL / Data Warehouse (Semana 1)

### 3.1 Decisión de motor (elige uno)

| Opción | Pros | Contras | Recomendación |
|---|---|---|---|
| **DuckDB (local)** | Sin instalación de servidor, lee CSV directo, rápido, gratis | No es "PostgreSQL" para CV | ⭐ Para empezar y para notebooks |
| **Supabase (Postgres free)** | PostgreSQL real (tu skill), API, 500MB gratis | Requiere carga | ⭐⭐ Para CV (PostgreSQL) |
| **Neon (Postgres free)** | Branching, 0.5GB | Similar a Supabase | Alternativa |

**Recomendación:** empieza con **DuckDB** (1 día). Si te sobra tiempo, replica en **Supabase** para tener PostgreSQL en el CV. Ambos son gratis.

### 3.2 Modelo estrella (DDL — `sql/03_star_model.sql`)

```sql
-- Dimensiones
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    month_name VARCHAR,
    quarter INT,
    day_of_week INT,
    is_weekend BOOLEAN
);

CREATE TABLE dim_customer (
    customer_key VARCHAR PRIMARY KEY,
    customer_unique_id VARCHAR,
    customer_city VARCHAR,
    customer_state VARCHAR,
    customer_zip_code_prefix VARCHAR
);

CREATE TABLE dim_product (
    product_key VARCHAR PRIMARY KEY,
    product_category_name VARCHAR,
    product_category_name_english VARCHAR,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE dim_seller (
    seller_key VARCHAR PRIMARY KEY,
    seller_city VARCHAR,
    seller_state VARCHAR
);

CREATE TABLE dim_geography (
    geo_key VARCHAR PRIMARY KEY,
    zip_code_prefix VARCHAR,
    lat DOUBLE,
    lng DOUBLE,
    city VARCHAR,
    state VARCHAR
);

-- Hechos
CREATE TABLE fact_orders (
    order_id VARCHAR PRIMARY KEY,
    customer_key VARCHAR REFERENCES dim_customer(customer_key),
    date_key INT REFERENCES dim_date(date_key),
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    delivery_days INT,
    is_late BOOLEAN
);

CREATE TABLE fact_order_items (
    order_item_id INT,
    order_id VARCHAR REFERENCES fact_orders(order_id),
    product_key VARCHAR REFERENCES dim_product(product_key),
    seller_key VARCHAR REFERENCES dim_seller(seller_key),
    price DOUBLE,
    freight_value DOUBLE,
    total_value DOUBLE
);

CREATE TABLE fact_payments (
    payment_id INT,
    order_id VARCHAR REFERENCES fact_orders(order_id),
    payment_type VARCHAR,
    payment_installments INT,
    payment_value DOUBLE
);

CREATE TABLE fact_reviews (
    review_id VARCHAR PRIMARY KEY,
    order_id VARCHAR REFERENCES fact_orders(order_id),
    review_score INT,
    review_comment_title VARCHAR,
    review_comment_message VARCHAR,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);
```

### 3.3 Queries clave (para el README y el dashboard)

**Q1 — Tendencia de ventas mensual**
```sql
-- sql/queries/q01_sales_trend.sql
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(DISTINCT f.order_id) AS orders,
    SUM(i.total_value) AS revenue,
    AVG(i.total_value) AS avg_ticket
FROM fact_orders f
JOIN fact_order_items i ON f.order_id = i.order_id
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.order_status = 'delivered'
GROUP BY 1,2,3
ORDER BY 1,2;
```

**Q2 — Top categorías por ingresos y rating**
```sql
-- sql/queries/q02_top_categories.sql
SELECT
    p.product_category_name_english AS category,
    COUNT(DISTINCT i.order_id) AS orders,
    SUM(i.total_value) AS revenue,
    AVG(r.review_score) AS avg_review,
    AVG(f.delivery_days) AS avg_delivery_days
FROM fact_order_items i
JOIN dim_product p ON i.product_key = p.product_key
JOIN fact_orders f ON i.order_id = f.order_id
LEFT JOIN fact_reviews r ON f.order_id = r.order_id
GROUP BY 1
ORDER BY revenue DESC
LIMIT 15;
```

**Q3 — Retrasos por estado**
```sql
-- sql/queries/q03_delivery_delays.sql
SELECT
    c.customer_state AS state,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN f.is_late THEN 1 ELSE 0 END) AS late_orders,
    ROUND(100.0 * SUM(CASE WHEN f.is_late THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_pct,
    AVG(f.delivery_days) AS avg_delivery_days
FROM fact_orders f
JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE f.order_status = 'delivered'
GROUP BY 1
ORDER BY late_pct DESC;
```

**Q4 — Base RFM**
```sql
-- sql/queries/q04_rfm_base.sql
WITH last_date AS (SELECT MAX(order_purchase_timestamp) AS max_date FROM fact_orders),
rfm AS (
    SELECT
        f.customer_key,
        DATE_DIFF('day', MAX(f.order_purchase_timestamp), (SELECT max_date FROM last_date)) AS recency,
        COUNT(DISTINCT f.order_id) AS frequency,
        SUM(i.total_value) AS monetary
    FROM fact_orders f
    JOIN fact_order_items i ON f.order_id = i.order_id
    WHERE f.order_status = 'delivered'
    GROUP BY 1
)
SELECT * FROM rfm;
```

**Q5 — Cohortes de retención**
```sql
-- sql/queries/q05_cohorts.sql
WITH first_purchase AS (
    SELECT customer_key, DATE_TRUNC('month', MIN(order_purchase_timestamp)) AS cohort_month
    FROM fact_orders WHERE order_status='delivered' GROUP BY 1
),
activity AS (
    SELECT f.customer_key, DATE_TRUNC('month', f.order_purchase_timestamp) AS activity_month
    FROM fact_orders f WHERE f.order_status='delivered'
)
SELECT
    fp.cohort_month,
    DATE_DIFF('month', fp.cohort_month, a.activity_month) AS month_number,
    COUNT(DISTINCT a.customer_key) AS customers
FROM first_purchase fp
JOIN activity a ON fp.customer_key = a.customer_key
GROUP BY 1,2
ORDER BY 1,2;
```

### 3.4 Script de carga (DuckDB) — `src/load_data.py`

```python
import duckdb, pandas as pd, glob, os

con = duckdb.connect("data/retail.duckdb")

# Cargar CSVs crudos
for csv in glob.glob("data/raw/*.csv"):
    name = os.path.basename(csv).replace("olist_", "").replace("_dataset.csv", "")
    con.execute(f"CREATE OR REPLACE TABLE {name} AS SELECT * FROM read_csv_auto('{csv}')")

# (Aquí irían los INSERT/transformaciones al modelo estrella)
print(con.execute("SHOW TABLES").fetchall())
```

Ejecutar: `python src/load_data.py`

---

## 4. Parte B — Power BI Dashboard (Semana 2)

### 4.1 Conexión
- **Opción A (DuckDB):** exportar tablas a Parquet (`COPY ... TO 'data/processed/x.parquet'`) y conectar Power BI a Parquet (vía ODBC o importando con Python script). Más complejo.
- **Opción B (Supabase/Postgres):** conectar Power BI directo a PostgreSQL (Get Data → PostgreSQL). ⭐ Recomendado para CV.
- **Opción C (CSV):** exportar cada tabla a CSV y cargar en Power BI. Más simple para empezar.

**Recomendación:** empieza con **Opción C (CSV)** para tener el dashboard rápido; si te sobra tiempo, migra a Supabase (Postgres).

### 4.2 Medidas DAX clave

```dax
Revenue = SUM(fact_order_items[total_value])
Orders = DISTINCTCOUNT(fact_orders[order_id])
Avg Ticket = DIVIDE([Revenue], [Orders])
Late % = DIVIDE(SUM(fact_orders[is_late]), [Orders])
Avg Delivery Days = AVERAGE(fact_orders[delivery_days])
Customers = DISTINCTCOUNT(fact_orders[customer_key])
```

### 4.3 Páginas del dashboard (5 páginas)

1. **Resumen Ejecutivo**
   - KPIs: Revenue, Orders, Avg Ticket, Late %, Avg Delivery Days, Customers.
   - Gráfico de líneas: Revenue por mes.
   - Mapa: Revenue por estado (Brasil).
   - Top 5 categorías (barras).

2. **Ventas y Categorías**
   - Matriz: categoría × (revenue, orders, avg_review).
   - Treemap de categorías.
   - Filtros: año, estado, categoría.

3. **Logística y Entregas**
   - Mapa de retrasos por estado (color = late %).
   - Histograma de días de entrega.
   - Tabla de vendedores con peor desempeño.

4. **Clientes (RFM)**
   - Scatter: recency vs monetary, color = segmento.
   - Donut: distribución de segmentos.
   - Tabla de top clientes.

5. **Reviews y Sentimiento**
   - Distribución de review_score.
   - Word cloud de comentarios negativos (custom visual).
   - Tabla de reviews 1-2 estrellas.

### 4.4 Publicación (gratis)

1. En Power BI Desktop: **File → Publish → My Workspace** (cuenta gratuita).
2. En Power BI Service: abrir el reporte → **File → Embed report → Publish to web (public)**.
3. Copiar la URL pública → será el `demoUrl` del proyecto.
4. Exportar PDF como backup (`powerbi/retail_intelligence.pdf`).

> ⚠️ "Publish to web" hace el reporte **público**. No subas datos sensibles. Olist es público, OK.

---

## 5. Parte C — IA / ML (Semana 3)

### 5.1 Segmentación RFM + K-Means — `notebooks/02_rfm_segmentation.ipynb`

```python
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

rfm = pd.read_sql("SELECT * FROM rfm_base", con)  # de sql/queries/q04_rfm_base.sql
X = StandardScaler().fit_transform(rfm[['recency','frequency','monetary']])
kmeans = KMeans(n_clusters=4, random_state=42, n_init=10)
rfm['segment'] = kmeans.fit_predict(X)

# Nombrar segmentos por perfil (ej. Champions, Loyal, At Risk, Lost)
# Exportar a CSV para Power BI
rfm.to_csv("data/processed/rfm_segments.csv", index=False)
```

**Entregable:** 4 segmentos nombrados + perfil (recency/frequency/monetary promedio) + CSV para Power BI.

### 5.2 Predicción de retraso de entrega — `notebooks/03_delay_prediction.ipynb`

**Target:** `is_late` (binario).  
**Features:** estado del cliente, estado del vendedor, categoría, precio, freight, distancia (lat/lon), día de la semana, mes.

```python
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, roc_auc_score
import shap

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
model = RandomForestClassifier(n_estimators=200, random_state=42, n_jobs=-1)
model.fit(X_train, y_train)

y_pred = model.predict(X_test)
y_proba = model.predict_proba(X_test)[:,1]
print(classification_report(y_test, y_pred))
print("ROC-AUC:", roc_auc_score(y_test, y_proba))

# Explicabilidad
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_test)
shap.summary_plot(shap_values[1], X_test)
```

**Métricas a reportar:** Precision, Recall, F1, ROC-AUC.  
**Entregable:** modelo guardado (`models/delay_model.pkl`), gráfico SHAP, métricas en README.

### 5.3 Análisis de sentimiento — `notebooks/04_sentiment_analysis.ipynb`

```python
import re, nltk
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression

# Usar review_score como label: 1-2 = negativo, 4-5 = positivo
df = pd.read_sql("SELECT review_score, review_comment_message FROM reviews WHERE review_comment_message IS NOT NULL", con)
df['label'] = df['review_score'].apply(lambda s: 1 if s >= 4 else 0 if s <= 2 else None)
df = df.dropna()

vec = TfidfVectorizer(max_features=5000, ngram_range=(1,2), stop_words='portuguese' if False else None)
X = vec.fit_transform(df['review_comment_message'].fillna(''))
# ... train/test + LogisticRegression + métricas
```

**Extra (IA for business):** extraer los top términos de reviews negativas (tf-idf) para listar "temas recurrentes" (ej. "atraso", "produto diferente", "embalagem").

**Entregable:** top 20 términos negativos + modelo + métricas.

---

## 6. Parte D — Repo GitHub y README (Semana 3)

### 6.1 README.md (plantilla)

```markdown
# Retail Intelligence — E-commerce Analytics End-to-End

Análisis end-to-end sobre el dataset Olist (e-commerce brasileño, ~100k pedidos):
SQL (modelo estrella) + Power BI (dashboard ejecutivo) + ML (predicción de retraso, segmentación RFM) + NLP (sentimiento de reviews).

## 🎯 Preguntas de negocio
- ...

## 📊 Demo
- Power BI (público): <URL>
- Notebook (nbviewer): <URL>

## 🗂️ Estructura
...

## 🛠️ Stack
Python, DuckDB/PostgreSQL, Power BI, scikit-learn, SHAP, Streamlit

## 📈 Resultados clave
- Revenue total: R$ X
- % pedidos retrasados: Y%
- ROC-AUC del modelo de retraso: Z
- 4 segmentos RFM: Champions (X%), ...

## 🚀 Cómo reproducir
1. Descargar dataset de Kaggle a data/raw/
2. pip install -r requirements.txt
3. python src/load_data.py
4. Abrir powerbi/retail_intelligence.pbix
5. Ejecutar notebooks/

## 📄 Licencia del dataset
CC BY-NC-SA 4.0 (Olist)
```

### 6.2 Subir a GitHub

```bash
cd C:\Proyectos\Retail_Intelligence
git init
git add .
git commit -m "feat: initial project structure"
git branch -M main
git remote add origin https://github.com/Alejndromaldonado/retail-intelligence.git
git push -u origin main
```

### 6.3 Publicar notebooks en nbviewer

Sube los `.ipynb` al repo → abre https://nbviewer.org → pega la URL del notebook en GitHub → copia el link de nbviewer → será el `notebookUrl`.

---

## 7. Parte E — Integración en tu portfolio web (Semana 3)

### 7.1 Cambios en `types.ts`

```ts
export interface Project {
  id: string;
  title: string;
  description: string;
  tags: string[];
  imageUrl: string;
  updatedAt: string;
  category: ProjectCategory;
  demoUrl?: string;
  repoUrl?: string;        // NUEVO
  notebookUrl?: string;    // NUEVO
  docsUrl?: string;        // NUEVO
  impact?: string[];       // NUEVO: bullets de impacto
  dataset?: string;        // NUEVO
}
```

### 7.2 Nuevo proyecto en `constants.ts`

```ts
{
  id: '7',
  title: 'Retail Intelligence — E-commerce Analytics End-to-End',
  description: 'Análisis end-to-end sobre ~100k pedidos de Olist: modelo estrella SQL, dashboard ejecutivo en Power BI, segmentación RFM + K-Means, predicción de retraso de entrega con Random Forest (SHAP) y análisis de sentimiento de reviews (NLP).',
  tags: ['SQL', 'Power BI', 'Python', 'Machine Learning', 'NLP'],
  imageUrl: '<screenshot real del dashboard Power BI>',
  updatedAt: 'Nov 2026',
  category: 'Power BI',   // o 'Python'
  demoUrl: '<URL Publish to web>',
  repoUrl: 'https://github.com/Alejndromaldonado/retail-intelligence',
  notebookUrl: '<URL nbviewer>',
  impact: [
    'Revenue total analizado: R$ X',
    '% pedidos retrasados: Y%',
    'ROC-AUC modelo de retraso: Z',
    '4 segmentos RFM identificados',
  ],
  dataset: 'Olist Brazilian E-Commerce (Kaggle)',
}
```

### 7.3 Actualizar `Projects.tsx` (opcional, cuando implementes)

- Agregar botones secundarios **Código** y **Notebook** además de "Explorar".
- Mostrar `impact` como bullets.
- Agregar campo `dataset` pequeño en gris.

### 7.4 Screenshots

- Tomar screenshot del dashboard Power BI (página "Resumen Ejecutivo") en 16:10.
- Subir a Cloudinary (ya lo usas) → URL en `imageUrl`.
- También screenshot del gráfico SHAP y del scatter RFM para el README.

### 7.5 Actualizar Stats

Reemplazar por métricas verificables, ej.:
- `3` proyectos end-to-end con código público
- `1` dashboard Power BI publicado
- `1` modelo ML con métricas reportadas

---

## 8. Checklist de entrega (Definition of Done)

- [ ] Repo público en GitHub con estructura completa.
- [ ] README con pitch, resultados, cómo reproducir, licencia del dataset.
- [ ] Al menos 5 queries SQL en `/sql/queries` con resultados en README.
- [ ] Modelo estrella documentado (`sql/03_star_model.sql`).
- [ ] Dashboard Power BI con 5 páginas publicado (Publish to web).
- [ ] PDF del dashboard en `/powerbi`.
- [ ] 4 notebooks ejecutados y limpios (sin errores).
- [ ] Modelo ML con métricas (Precision/Recall/F1/ROC-AUC) y gráfico SHAP.
- [ ] Segmentación RFM con 4 segmentos nombrados.
- [ ] NLP: top términos de reviews negativas.
- [ ] Integrado en portfolio web (card + links + screenshot real).
- [ ] CV y LinkedIn actualizados con el proyecto + links.

---

## 9. Métricas de éxito del proyecto (para tu CV)

Reporta números reales (ejemplos, reemplaza con los tuyos):
- "Analizados **~100k pedidos** de e-commerce brasileño (2016-2018)."
- "Construido **modelo estrella** con 9 tablas y **5 KPIs** de negocio."
- "Dashboard Power BI con **5 páginas** y **Publish to web**."
- "Modelo de predicción de retraso: **ROC-AUC X**, **Precision Y**."
- "Segmentación RFM: **4 segmentos**, Champions = Z% del revenue."
- "NLP: **top 20 temas** en reviews negativas."

---

## 10. Costos y límites (gratis)

| Recurso | Free tier | Límite a vigilar |
|---|---|---|
| Kaggle dataset | Gratis | Descarga manual |
| DuckDB | Gratis | Local (sin límite práctico) |
| Supabase | 500 MB, 2 proyectos | Si migras a Postgres |
| Power BI Service | Publish to web | Reporte público |
| GitHub | Repos públicos ilimitados | Archivos <100MB |
| Streamlit Cloud | 1 app, repo público | Cold start |
| Databricks CE | 1 cluster | Se apaga por inactividad |

**Regla de oro:** nunca subas `.pbix`, `.pkl` ni CSVs crudos al repo (`.gitignore`). Usa GitHub Releases o Drive para binarios.

---

## 11. Troubleshooting

- **Power BI no conecta a DuckDB:** exporta a CSV/Parquet y carga por archivo.
- **Publish to web deshabilitado:** tu admin de tenant puede bloquearlo; usa cuenta personal de Power BI (no corporativa) para el portfolio.
- **scikit-learn SHAP lento:** usa `TreeExplainer` (rápido para Random Forest). Reduce muestra a 1000 filas para el plot.
- **NLP en portugués:** usa `stop_words` manual o lista de stopwords en portugués (NLTK tiene `portuguese`).
- **nbviewer no renderiza:** asegúrate de que el notebook esté en un repo público y sin outputs pesados.

---

## 12. Recursos

- Dataset: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
- Power BI Publish to web: https://learn.microsoft.com/power-bi/collaborate-share/service-publish-to-web
- DuckDB docs: https://duckdb.org/docs
- scikit-learn: https://scikit-learn.org
- SHAP: https://shap.readthedocs.io
- nbviewer: https://nbviewer.org
- Supabase: https://supabase.com

---

## 13. Próximos pasos inmediatos (hoy)

1. Crear cuenta en Kaggle (si no la tienes) y descargar el dataset.
2. Descomprimir en `data/raw/`.
3. Crear el repo en GitHub: `retail-intelligence`.
4. Copiar esta estructura de carpetas.
5. Instalar dependencias: `pip install -r requirements.txt`.
6. Empezar con `notebooks/01_eda.ipynb`.

---

> **Nota:** este plan es para el Proyecto P1. Cuando lo termines, los proyectos P2 (Big Data PySpark) y P3 (Churn ML) siguen el mismo patrón: dataset → SQL/warehouse → análisis → ML → demo → repo → integración en portfolio.
