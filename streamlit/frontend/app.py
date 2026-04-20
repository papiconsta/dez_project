import os
import streamlit as st
from google.cloud import bigquery
from dotenv import load_dotenv
import pandas as pd

load_dotenv()

PROJECT = os.getenv("GCP_PROJECT")
DATASET = os.getenv("GCP_DATASET")

st.set_page_config(page_title="Government Contracts Dashboard", layout="wide")
st.title("Canadian Government Contracts Dashboard")

@st.cache_data
def query(sql):
    client = bigquery.Client(project=PROJECT)
    return client.query(sql).to_dataframe()


# ── Spend over time ───────────────────────────────────────────────────────────
st.header("Spend Over Time")
df_time = query(f"SELECT * FROM `{PROJECT}.{DATASET}.mart_spend_over_time` ORDER BY year")
st.line_chart(df_time.set_index("year")[["total_spend", "total_contracts"]])


# ── Spend by department ───────────────────────────────────────────────────────
st.header("Spend by Department")
df_dept = query(f"SELECT * FROM `{PROJECT}.{DATASET}.mart_spend_by_department` LIMIT 20")
st.bar_chart(df_dept.set_index("owner_acronym")["total_spend"])


# ── Top vendors ───────────────────────────────────────────────────────────────
st.header("Top Vendors by Contract Value")
df_vendors = query(f"SELECT * FROM `{PROJECT}.{DATASET}.mart_top_vendors` LIMIT 20")
st.bar_chart(df_vendors.set_index("gen_vendor_normalized")["total_spend"])


# ── Spend by category ─────────────────────────────────────────────────────────
st.header("Spend by Category")
df_cat = query(f"SELECT * FROM `{PROJECT}.{DATASET}.mart_spend_by_category` LIMIT 15")
st.dataframe(df_cat[["description", "total_contracts", "total_spend", "avg_contract_value"]], use_container_width=True)
