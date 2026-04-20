from datetime import datetime, timedelta
import logging

from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from docker.types import Mount

log = logging.getLogger(__name__)

DBT_HOST_DIR = "/home/papiconstantinos/dez_project/dbt"
SECRETS_HOST_DIR = "/home/papiconstantinos/secrets"
NETWORK = "dez_project_default"

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}


def on_start(context):
    task_id = context['task_instance'].task_id
    log.info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    log.info("Starting task: %s", task_id)
    log.info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")


def on_success(context):
    task_id = context['task_instance'].task_id
    log.info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    log.info("Task completed successfully: %s", task_id)
    log.info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")


def on_failure(context):
    task_id = context['task_instance'].task_id
    log.error("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    log.error("Task FAILED: %s", task_id)
    log.error("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")


with DAG(
    dag_id='dbt_aggregations_dag',
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
) as dag:

    dbt_run = DockerOperator(
        task_id='dbt_run',
        image='dez-dbt:latest',
        command='dbt run --select marts --profiles-dir /dbt',
        working_dir='/dbt',
        mounts=[
            Mount(source=DBT_HOST_DIR, target='/dbt', type='bind'),
            Mount(source=SECRETS_HOST_DIR, target='/secrets', read_only=True, type='bind'),
        ],
        environment={'GOOGLE_APPLICATION_CREDENTIALS': '/secrets/service-account.json'},
        auto_remove='success',
        docker_url='unix://var/run/docker.sock',
        network_mode=NETWORK,
        on_execute_callback=on_start,
        on_success_callback=on_success,
        on_failure_callback=on_failure,
    )

    dbt_test = DockerOperator(
        task_id='dbt_test',
        image='dez-dbt:latest',
        command='dbt test --select marts --profiles-dir /dbt',
        working_dir='/dbt',
        mounts=[
            Mount(source=DBT_HOST_DIR, target='/dbt', type='bind'),
            Mount(source=SECRETS_HOST_DIR, target='/secrets', read_only=True, type='bind'),
        ],
        environment={'GOOGLE_APPLICATION_CREDENTIALS': '/secrets/service-account.json'},
        auto_remove='success',
        docker_url='unix://var/run/docker.sock',
        network_mode=NETWORK,
        on_execute_callback=on_start,
        on_success_callback=on_success,
        on_failure_callback=on_failure,
    )

    dbt_run >> dbt_test
