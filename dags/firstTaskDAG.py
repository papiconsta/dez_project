from datetime import datetime, timedelta
import logging

from airflow import DAG
from airflow.operators.python import PythonOperator

log = logging.getLogger(__name__)


from scripts.getData import getDataFromBucketToLocal
from scripts.createSchema import getDataFromLocalForSchemaExtractionAndCreateTableToBigQuery


default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

def task1_wrapper():
    log.info("Starting Task 1: Fetching data from GCS to local storage.")

    # return value gets stored in XCom automatically
    num_files = getDataFromBucketToLocal(
        bucket_name="demo-bucket-terraform-project-a15ee64e-db9e-4b3a-879",
        directory="/tmp/data/"
    )
    return num_files
    
def task2_wrapper():
    log.info("Starting Task 2: Extracting schema and creating table in BigQuery.")
    import os
    directory = "/tmp/data/"
    files = [os.path.join(directory, f) for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f))]
    getDataFromLocalForSchemaExtractionAndCreateTableToBigQuery(
        files=files
    )


with DAG(
    dag_id='first_dag_DEZ',
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule='@daily',
    catchup=False,
) as dag:
    task1 = PythonOperator(
        task_id='task1_fetch',
        python_callable=task1_wrapper,
    )
    task2 = PythonOperator(
        task_id='task2_schema',
        python_callable=task2_wrapper,
    )
    
    task1 >> task2
