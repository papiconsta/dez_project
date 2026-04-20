FROM apache/airflow:2.9.0

COPY requirements.txt .
RUN pip install --no-cache-dir \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.9.0/constraints-3.12.txt" \
    -r requirements.txt
