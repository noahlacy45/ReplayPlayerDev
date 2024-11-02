# ReplayPlayerDev
# 10/18 & 10/19 2024 -- Noah Lacy added the CombineBlastSheets.py file to combine all the sheets from Blast into 1 data frame & csv which also pulls in the player name by email associated with the account. 

# How to Start the Process

## Go to Blast Insights page, select the date range you need, click the 3 dots in the top right, select "Save Full Team Report - Excel". A link will be emailed to the admins email account, click on that and an excel file will begin downloading. Import the file into Google Sheets and delete the Team Report tab. Save the file as an Excel file and name it the date range. Add the new file to the 'BlastData' file in the correct month and year (mmYY) sub folder. Run the 'CombineBlastSheets.py' file, but you'll need to change the file path on line 7. Then run the 'CreateMasterData.py' file to bring all the output files together. 