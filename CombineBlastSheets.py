import pandas as pd
import os
from datetime import datetime

# Define the path to your Excel file
# !! MAKE SURE YOU CHANGE THE FILE NAME EACH UPLOAD !!
excel_file_path = r"C:\Users\noahl\OneDrive\Documents\Git Repos\ReplayPlayerDev\BlastData\Oct24\Oct16-Oct21.xlsx"

# Define the path to the CSV file for player names
player_csv_path = r"C:\Users\noahl\OneDrive\Documents\Git Repos\ReplayPlayerDev\BlastData\PlayerName\Blast Players_Oct24.csv"

# Define the output folder (make sure this folder exists)
output_folder = r"C:\Users\noahl\OneDrive\Documents\Git Repos\ReplayPlayerDev\BlastData\Output"

# Create a list to hold the modified DataFrames
all_data = []

# Read the sheet names
sheet_names = pd.ExcelFile(excel_file_path).sheet_names

# Loop through each sheet name
for sheet in sheet_names:
    # Read the value from cell B3
    b3_value = pd.read_excel(excel_file_path, sheet_name=sheet, header=None, usecols="B", nrows=3).iloc[2, 0]

    # Read the data from the sheet starting from row 9
    data = pd.read_excel(excel_file_path, sheet_name=sheet, header=8)

    # Create a new column using the value from cell B3
    data['Email'] = b3_value

    # Append the modified DataFrame to the list
    all_data.append(data)

# Concatenate all modified DataFrames into a single DataFrame
combined_data = pd.concat(all_data, ignore_index=True)

# Read the player CSV file
player_df = pd.read_csv(player_csv_path)

# Perform the join operation on the 'Email' column to get 'Player_Name'
final_df = pd.merge(combined_data, player_df[['Email', 'Player_Name']], on='Email', how='left')

# Create a dynamic filename with the current date
date_str = datetime.now().strftime("%Y-%m-%d")
output_file_name = f"combined_data_{date_str}.csv"
output_file_path = os.path.join(output_folder, output_file_name)

# Save the final DataFrame to a new CSV file
final_df.to_csv(output_file_path, index=False)

# Print the path of the saved CSV file
print(f"Data saved to: {output_file_path}")
