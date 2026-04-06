import os
import logging
from google.cloud import storage

log = logging.getLogger(__name__)

def getDataFromBucketToLocal(bucket_name,directory):
    """
        this functions gets the bucket_name and the directory in
        which the user wants to save the file

        DEFAULT VALUE OF directory will be / which means where the airflow
        DAG Will be generated.
    """


    os.makedirs(directory, exist_ok=True)

    # connects using your gcloud auth
    client = storage.Client(project="dataengineeringproject-491413")

    # check connection
    log.info(f"Connected to project: {client.project}")

    # list all files
    blobs = client.list_blobs(bucket_name)

    downloaded = []
    for blob in blobs:
        local_path = f"{directory}{blob.name}"
        blob.download_to_filename(local_path)
        log.info(f"File {blob.name} downloaded successfully.")
        downloaded.append(local_path)

    return downloaded