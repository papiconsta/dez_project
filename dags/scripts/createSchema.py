import logging
import pandas as pd
from google.cloud import bigquery

log = logging.getLogger(__name__)

DTYPE_TO_BQ = {
    'int64':   'INTEGER',
    'int32':   'INTEGER',
    'float64': 'FLOAT',
    'float32': 'FLOAT',
    'bool':    'BOOLEAN',
    'object':  'STRING',
    'datetime64[ns]':        'TIMESTAMP',
    'datetime64[us]':        'TIMESTAMP',
    'datetime64[ns, UTC]':   'TIMESTAMP',
    'datetime64[us, UTC]':   'TIMESTAMP',
}

def getDataFromLocalForSchemaExtractionAndCreateTableToBigQuery(files, dataset_id='staging', project_id='dataengineeringproject-491413'):
    """
        Receives the list of local file paths downloaded by task1,
        reads each file, extracts its schema, and creates a table in BigQuery.
    """
    client = bigquery.Client(project=project_id)
    log.info(f"Connected to BigQuery project: {client.project}")

    for file in files:
        df = pd.read_parquet(file) if file.endswith('.parquet') else pd.read_csv(file, nrows=1000, encoding='latin-1')
        log.info(f"Now getting schema for file: {file}")
        log.info(f"\n{df.dtypes}")

        # build BigQuery schema from dataframe dtypes
        bq_schema = []
        for col, dtype in df.dtypes.items():
            bq_type = DTYPE_TO_BQ.get(str(dtype), 'STRING')
            bq_schema.append(bigquery.SchemaField(col, bq_type))

        # derive table name from file name (e.g. yellow_tripdata_2026-01)
        table_name = file.split('/')[-1].replace('.parquet', '').replace('.csv', '')
        table_ref = f"{project_id}.{dataset_id}.{table_name}"

        table = bigquery.Table(table_ref, schema=bq_schema)
        table = client.create_table(table, exists_ok=True)
        log.info(f"Table {table_ref} created/verified in BigQuery.")
