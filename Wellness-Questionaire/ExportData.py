import gspread
from google.oauth2.service_account import Credentials
import pandas as pd

# Path to your service account key JSON file
SERVICE_ACCOUNT_FILE = r"C:\Users\noahl\OneDrive\Documents\Google Key\tidal-horizon-440420-n7-e6d34a1895a8.json"

# Define the scope and authenticate
SCOPES = ["https://www.googleapis.com/auth/spreadsheets.readonly"]
creds = Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)

# Connect to Google Sheets
client = gspread.authorize(creds)

# Open your Google Sheet by name or by URL
spreadsheet = client.open_by_url("https://docs.google.com/spreadsheets/d/1giB3NW7Z7BuFPND-c5OaG0FJppz4d4A7mjXwguSpoGw/edit?resourcekey=&gid=1630943057#gid=1630943057")  # Alternatively, you can use client.open_by_url(URL)

# Select the worksheet by name
worksheet = spreadsheet.worksheet("Form Responses 1")

# Get all values in the sheet as a list of lists
data = worksheet.get_all_values()

# Convert the data to a DataFrame, assuming the first row is the header
df = pd.DataFrame(data[1:], columns=data[0])

# Define the path for the CSV file
csv_path = r"C:\Users\noahl\OneDrive\Documents\Git Repos\ReplayPlayerDev\Wellness-Questionaire\wellness_data.csv"

# Save DataFrame to CSV
df.to_csv(csv_path, index=False)

print(f"Data has been saved to {csv_path}")
