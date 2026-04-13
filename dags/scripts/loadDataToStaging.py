import logging
import pandas as pd
from google.cloud import bigquery

log = logging.getLogger(__name__)

CHUNK_SIZE = 50_000

def _cast_chunk(chunk, bq_schema):
    for field in bq_schema:
        if field.name not in chunk.columns:
            continue
        try:
            if field.field_type == 'INTEGER':
                chunk[field.name] = pd.to_numeric(chunk[field.name], errors='coerce').astype('Int64')
            elif field.field_type == 'FLOAT':
                chunk[field.name] = pd.to_numeric(chunk[field.name], errors='coerce')
            elif field.field_type == 'TIMESTAMP':
                chunk[field.name] = pd.to_datetime(chunk[field.name], errors='coerce')
            elif field.field_type == 'BOOLEAN':
                chunk[field.name] = chunk[field.name].astype('boolean')
        except Exception as e:
            log.warning(f"Could not cast column {field.name} ({field.field_type}): {e}")
    return chunk

def loadDataToStaging(files, dataset_id='staging', project_id='dataengineeringproject-491413'):
    """
        Receives the list of local file paths downloaded by task1,
        reads each file in chunks, casts columns to match the BigQuery table schema,
        and loads the data.
    """
    client = bigquery.Client(project=project_id)
    log.info(f"Connected to BigQuery project: {client.project}")

    for file in files:
        table_name = file.split('/')[-1].replace('.parquet', '').replace('.csv', '')
        table_ref = f"{project_id}.{dataset_id}.{table_name}"
        bq_schema = client.get_table(table_ref).schema

        job_config = bigquery.LoadJobConfig(
            write_disposition=bigquery.WriteDisposition.WRITE_APPEND
        )

        if file.endswith('.parquet'):
            df = pd.read_parquet(file)
            df = df.dropna()
            df = _cast_chunk(df, bq_schema)
            client.load_table_from_dataframe(df, table_ref, job_config=job_config).result()
            log.info(f"Loaded {len(df)} rows from {file} into {table_ref}.")
        else:
            total = 0
            for i, chunk in enumerate(pd.read_csv(file, encoding='latin-1', chunksize=CHUNK_SIZE)):
                chunk = chunk.dropna()
                chunk = _cast_chunk(chunk, bq_schema)
                client.load_table_from_dataframe(chunk, table_ref, job_config=job_config).result()
                total += len(chunk)
                log.info(f"Chunk {i+1}: loaded {len(chunk)} rows. Total so far: {total}.")
            log.info(f"Finished loading {file} into {table_ref}. Total rows: {total}.")
