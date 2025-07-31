This file explains the different files in the gcp-pipeline-folder

csv_detection

This file is the Google App Script that will run on the Google Drive folders, and is what will trigger the cloud function.

deployment_command

This file is what is ran in the Cloud Shell terminal after creating the ingestion function (main.py and requirements.txt). This deploys the cloud function.

main.py

This file is the main code for the Google Cloud Platform function.

requirements.txt

This file is needed for the Google Cloud Platform function so it can run.

