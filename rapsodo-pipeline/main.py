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

connector = None

def get_conn():
    """Initializes connector on first use and creates a connection."""
    global connector
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
def rapsodo_ingest_csv(request):
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

                # --- DATA CLEANING AND PARSING START ---
                lines = [line for line in csv_data.strip().splitlines() if line.strip()]
                logging.info(f"First 5 non-empty lines: {lines[:5]}")

                player_id = lines[0].split(',')[1].strip().strip('"')
                player_name = lines[1].split(',')[1].strip().strip('"')

                data_string = "\n".join(lines[2:])
                reader = csv.DictReader(io.StringIO(data_string))

                original_headers = reader.fieldnames
                if not original_headers:
                    return ('CSV file is empty or missing headers', 400)

                header_mapping = {
                    "No": "No", "Date": "Date", "Pitch ID": "Pitch_ID", "Pitch Type": "Pitch_Type",
                    "Is Strike": "Is_Strike", "Strike Zone Side": "Strike_Zone_Side",
                    "Strike Zone Height": "Strike_Zone_Height", "Velocity": "Velocity",
                    "Total Spin": "Total_Spin", "True Spin (release)": "True_Spin_Release",
                    "Spin Efficiency (release)": "Spin_Efficiency_Release", "Spin Direction": "Spin_Direction",
                    "Spin Confidence": "Spin_Confidence", "VB (trajectory)": "VB_Trajectory",
                    "HB (trajectory)": "HB_Trajectory", "SSW VB": "SSW_VB", "SSW HB": "SSW_HB",
                    "VB (spin)": "VB_Spin", "HB (spin)": "HB_Spin", "Horizontal Angle": "Horizontal_Angle",
                    "Release Angle": "Release_Angle", "Release Height": "Release_Height",
                    "Release Side": "Release_Side", "Gyro Degree (deg)": "Gyro_Degree",
                    "Unique ID": "Unique_ID", "Device Serial Number": "Device_Serial_Number",
                    "SO - latLongConfidence": "SO_latLongConfidence", "SO - latitude": "SO_latitude",
                    "SO - longitude": "SO_longitude", "SO - rotMatConfidence": "SO_rotMatConfidence",
                    "SO - timestamp": "SO_timestamp", "SO - Xx": "SO_Xx", "SO - Xy": "SO_Xy",
                    "SO - Xz": "SO_Xz", "SO - Yx": "SO_Yx", "SO - Yy": "SO_Yy", "SO - Yz": "SO_Yz",
                    "SO - Zx": "SO_Zx", "SO - Zy": "SO_Zy", "SO - Zz": "SO_Zz",
                    "Horizontal Approach Angle": "Horizontal_Approach_Angle",
                    "Vertical Approach Angle": "Vertical_Approach_Angle", "Session Name": "Session_Name",
                    "Intent Type": "Intent_Type", "Release Extension (ft)": "Release_Extension_ft"
                }

                db_columns = ["Player_ID", "Player_Name"]
                for header in original_headers:
                    db_columns.append(header_mapping.get(header, header))

                data_to_insert = []
                for row in reader:
                    cleaned_values = []
                    for value in row.values():
                        # Normalize blank/missing values like "-" or "" to None
                        if value is None or value.strip() in ["", "-"]:
                            cleaned_values.append(None)
                        else:
                            cleaned_values.append(value)
                    new_row = [player_id, player_name] + cleaned_values
                    data_to_insert.append(new_row)

                logging.info(f"Parsed {len(data_to_insert)} rows in {time.time() - parsing_start:.2f} seconds.")
                if not data_to_insert:
                    return ('No data rows found in CSV', 200)

                insert_start = time.time()
                placeholders = ', '.join(['%s'] * len(db_columns))
                columns = ', '.join(f"`{col}`" for col in db_columns)
                sql = f"INSERT INTO `{table_name}` ({columns}) VALUES ({placeholders})"

                cursor.executemany(sql, data_to_insert)
                connection.commit()
                logging.info(f"Inserted {len(data_to_insert)} rows in {time.time() - insert_start:.2f} seconds.")

        logging.info(f"Total execution time: {time.time() - start_time:.2f} seconds.")
        return ('CSV data inserted successfully', 200)

    except Exception as e:
        logging.error(f"Error during ingest_csv: {e}", exc_info=True)
        return (f'Error: {str(e)}', 500)
