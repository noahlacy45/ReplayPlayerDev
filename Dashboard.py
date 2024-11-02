# Run "bokeh serve --show Dashboard.py" in the terminal for the dashboard to populate in browser

import pandas as pd
from bokeh.io import curdoc
from bokeh.layouts import column, row
from bokeh.models import ColumnDataSource, Select, Div, CustomJS, DatePicker
from bokeh.plotting import figure

# Load data from CSV and handle any potential errors with a try-except
data = pd.read_csv(r'C:\Users\noahl\OneDrive\Documents\Git Repos\ReplayPlayerDev\MasterData\MasterBlastData.csv')

# Ensure columns are of string type
data['Player_Name'] = data['Player_Name'].astype(str)
data['Swing_Details'] = data['Swing_Details'].astype(str)

# ColumnDataSource
source = ColumnDataSource(data=data)

# Plot setup
plot = figure(title="Bat Speed vs Rotational Acceleration", 
                x_axis_label='Bat Speed', 
                y_axis_label='Rotational Acceleration', 
                width=800, height=400)
scatter = plot.circle('Bat_Speed', 'Rotational_Acceleration', source=source, size=10, color="navy", alpha=0.5)

# Dropdown menus
player_names = ["All Players"] + sorted(data['Player_Name'].unique().tolist())
dropdown_player = Select(title="Select Player:", value="All Players", options=player_names)

swing_details_options = ["All Swings"] + sorted(data['Swing_Details'].unique().tolist())
dropdown_swing = Select(title="Select Swing Details:", value="All Swings", options=swing_details_options)

# Set dynamic color based on score
def get_color(score):
    if score >= 60:
        return "green"
    elif score >= 40:
        return "orange"
    else:
        return "red"

# Calculate initial averages for KPIs
initial_avg_plane_score = data['Plane_Score'].mean()
initial_avg_connection_score = data['Connection_Score'].mean()
initial_avg_rotation_score = data['Rotation_Score'].mean()

# Initial KPI display with colors
plane_score_color = get_color(initial_avg_plane_score)
connection_score_color = get_color(initial_avg_connection_score)    
rotation_score_color = get_color(initial_avg_rotation_score)

kpi_div = Div(text=f"""
    <div style='font-size: 18px; color: #333; width: 100%; text-align: center;'>
        Average Plane Score: <span style='color: {plane_score_color};'>{initial_avg_plane_score:.2f}</span> 
        | Average Connection Score: <span style='color: {connection_score_color};'>{initial_avg_connection_score:.2f}</span>
        | Average Rotation Score: <span style='color: {rotation_score_color};'>{initial_avg_rotation_score:.2f}</span>
    </div>
""", width=800, height=50)

# Update function for dropdown selections
def update(attr, old, new):
    selected_player = dropdown_player.value
    selected_swing = dropdown_swing.value

    # Filter data based on dropdown selections
    if selected_player == "All Players" and selected_swing == "All Swings":
        new_data = data
    elif selected_player == "All Players":
        new_data = data[data['Swing_Details'] == selected_swing]
    elif selected_swing == "All Swings":
        new_data = data[data['Player_Name'] == selected_player]
    else:
        new_data = data[(data['Player_Name'] == selected_player) & (data['Swing_Details'] == selected_swing)]

    # Update source data for scatter plot
    source.data = {
        'Bat_Speed': new_data['Bat_Speed'],
        'Rotational_Acceleration': new_data['Rotational_Acceleration']
    }

    # Calculate and update KPI values for the selected data
    avg_plane_score = new_data['Plane_Score'].mean()
    avg_connection_score = new_data['Connection_Score'].mean()
    avg_rotation_score = new_data['Rotation_Score'].mean()
    
    plane_score_color = get_color(avg_plane_score)
    connection_score_color = get_color(avg_connection_score)
    rotation_score_color = get_color(avg_rotation_score)
    
    kpi_div.text = f"""
        <div style='font-size: 18px; color: #333; width: 100%; text-align: center;'>
            <span>Average Plane Score: <span style='color: {plane_score_color};'>{avg_plane_score:.2f}</span></span> 
            | <span>Average Connection Score: <span style='color: {connection_score_color};'>{avg_connection_score:.2f}</span></span> 
            | <span>Average Rotation Score: <span style='color: {rotation_score_color};'>{avg_rotation_score:.2f}</span></span>
        </div>"""

# Attach update functions to dropdowns
dropdown_player.on_change('value', update)
dropdown_swing.on_change('value', update)

# Arrange dropdowns in a row and layout the entire dashboard
dropdown_row = row(dropdown_player, dropdown_swing)
layout = column(dropdown_row, kpi_div, plot)

curdoc().add_root(layout)
