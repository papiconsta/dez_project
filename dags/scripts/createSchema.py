import logging
import pandas as pd

log = logging.getLogger(__name__)

def getDataFromLocalForSchemaExtractionAndCreateTableToBigQuery(files):
    """
        Receives the list of local file paths downloaded by task1,
        reads each file and extracts its schema.
    """

    for file in files:
        df = pd.read_parquet(file)
        log.info(f"Now getting schema for file: {file}")
        log.info(f"\n{df.dtypes}")
