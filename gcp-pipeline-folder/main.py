import functions_framework
import csv
import io
import os
import pymysql
import logging
import time
from google.cloud.sql.connector import Connector

# Configure logging
logging.basicConfig(level=logging.INFO)

# Leave the connector as a global variable, but don't initialize it yet
connector = None

def get_conn():
    """Initializes connector on first use and creates a connection."""
    global connector
    # The first time this is called, the connector will be initialized.
    # On subsequent calls within the same function instance, it will be reused.
    if not connector:
        connector = Connector()

    conn = connector.connect(
        os.environ["INSTANCE_CONNECTION_NAME"],
        "pymysql",
        user=os.environ["MYSQL_USER"],
        password=os.environ["MYSQL_PASSWORD"],
        db=os.environ["MYSQL_DATABASE"]
    )
    return conn

@functions_framework.http
def ingest_csv(request):
    start_time = time.time()
    try:
        request_json = request.get_json(silent=True)
        if not request_json or 'csvData' not in request_json or 'filename' not in request_json:
            return ('Missing csvData or filename', 400)

        csv_data = request_json['csvData']
        table_name = os.environ.get('MYSQL_TABLE', 'rapsodo_data')
        logging.info(f"Function started for file: {request_json.get('filename')}")

        connection_start = time.time()
        connection = get_conn()
        logging.info(f"Database connection established in {time.time() - connection_start:.2f} seconds.")

        with connection:
            with connection.cursor() as cursor:
                parsing_start = time.time()
                reader = csv.DictReader(io.StringIO(csv_data))
                headers = reader.fieldnames
                if not headers:
                    return ('CSV file is empty or missing headers', 400)
                
                data_to_insert = [list(row.values()) for row in reader]
                logging.info(f"Parsed {len(data_to_insert)} rows in {time.time() - parsing_start:.2f} seconds.")

                if not data_to_insert:
                    return ('No data rows found in CSV', 200)

                insert_start = time.time()
                placeholders = ', '.join(['%s'] * len(headers))
                columns = ', '.join(f"`{col}`" for col in headers)
                sql = f"INSERT INTO `{table_name}` ({columns}) VALUES ({placeholders})"
                
                cursor.executemany(sql, data_to_insert)
                connection.commit()
                logging.info(f"Inserted {len(data_to_insert)} rows in {time.time() - insert_start:.2f} seconds.")

        logging.info(f"Total execution time: {time.time() - start_time:.2f} seconds.")
        return ('CSV data inserted successfully', 200)

    except Exception as e:
        logging.error(f"Error during ingest_csv: {e}", exc_info=True)
        return (f'Error: {str(e)}', 500)
