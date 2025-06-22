# DO NOT USE - OUTDATED

import pandas as pd
import os

# Define the directory containing the CSV files
csv_directory = r"C:\Users\noahl\OneDrive\Documents\Git Repos\ReplayPlayerDev\BlastData\Output"

# List to hold DataFrames
dataframes = []

# Loop through all CSV files in the directory
for file in os.listdir(csv_directory):
    if file.endswith('.csv'):
        # Create the full file path
        file_path = os.path.join(csv_directory, file)
        # Read the CSV file
        df = pd.read_csv(file_path)
        # Append the DataFrame to the list
        dataframes.append(df)

# Concatenate all DataFrames into a single DataFrame
master_dataframe = pd.concat(dataframes, ignore_index=True)

# !! AGGREGATION/FIELD CREATION HAPPENS BELOW !!

# Calculate the average of the 'Peak Hand Speed (mph)' for each player
average_peak_hand_speed = master_dataframe.groupby('Email')['Peak Hand Speed (mph)'].transform('mean')

# Create a new column 'Swing_Efficiency'
master_dataframe['Swing_Efficiency'] = master_dataframe['Bat Speed (mph)'] / average_peak_hand_speed

# !!AGGREGATION/FIELD CREATION HAPPENS ABOVE !!

# !! CHANGE COLUMN NAMES BELOW !!

master_dataframe.rename(columns={
    'Swing Details': 'Swing_Details',
    'Plane Score': 'Plane_Score',
    'Connection Score': 'Connection_Score',
    'Rotation Score' : 'Rotation_Score',
    'Bat Speed (mph)' : 'Bat_Speed',
    'Rotational Acceleration (g)' : 'Rotational_Acceleration',
    'On Plane Efficiency (%)' : 'On_Plane_Efficiency', 
    'Attack Angle (deg)' : 'Attack_Angle', 
    'Early Connection (deg)' : 'Early_Connection', 
    'Connection at Impact (deg)' : 'Connection_At_Impact', 
    'Vertical Bat Angle (deg)' : 'Vertical_Bat_Angle', 
    'Power (kW)' : 'Power', 
    'Time to Contact (sec)' : 'Time_to_Contact', 
    'Peak Hand Speed (mph)' : 'Peak_Hand_Speed',
    'Exit Velocity (mph)' : 'Exit_Velo_Blast',
    'Launch Angle (deg)' : 'Launch_Angle_Blast', 
    'Estimated Distance (feet)' : 'Estimated_Distance_Blast'    
}, inplace=True)

# !! cHANGE COLUMN NAMES ABOVE !!

# Display the master DataFrame
#print(master_dataframe)

# Remove duplicates
master_dataframe = master_dataframe.drop_duplicates()

# Optionally, save the master DataFrame to a new CSV file
master_dataframe.to_csv(r"C:\Users\noahl\OneDrive\Documents\Git Repos\ReplayPlayerDev\MasterData\MasterBlastData.csv", index=False)


