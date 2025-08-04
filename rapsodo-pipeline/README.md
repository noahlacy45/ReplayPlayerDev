This file explains the different files in the rapsodo-pipeline folder

rapsodo_csv_detection

This file is the Google App Script that will run on the Google Drive folders, and is what will trigger the cloud function. This is specific for the Rapsodo data.

rapsodo_deployment_command

This file is what is ran in the Cloud Shell terminal after creating the ingestion function (main.py and requirements.txt). This deploys the cloud function. This is specific for the Rapsodo data.

main.py

This file is the main code for the Google Cloud Platform function. This main.py is different than the main.py in the gcp-pipeline-folder (has data cleansing step).

requirements.txt

This file is needed for the Google Cloud Platform function so it can run.
