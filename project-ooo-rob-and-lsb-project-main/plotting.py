import pandas as pd
import matplotlib.pyplot as plt
import os

def plot_benchmark_data(file_path, sweep_type):
    # Extract benchmark name from file name
    benchmark_name = os.path.basename(file_path).split('_trace_')[0]
    
    # Load the CSV file into a pandas DataFrame
    data = pd.read_csv(file_path)
    
    # Define the sweep variable
    sweep_variable = sweep_type.upper()  # IPC, LSQ, or ROB
    
    # Create a dual-axis plot
    fig, ax1 = plt.subplots()

    # Plot Execution Time
    ax1.set_xlabel(sweep_variable)
    ax1.set_ylabel('Execution Time', color='tab:blue')
    ax1.plot(data[sweep_variable], data['Execution Time'], label='Execution Time (# of cycles)', color='tab:blue', marker='o')
    ax1.tick_params(axis='y', labelcolor='tab:blue')

    # Create a secondary axis for LSB Hits
    ax2 = ax1.twinx()
    ax2.set_ylabel('LSB Hits', color='tab:orange')
    ax2.plot(data[sweep_variable], data['LSB Hits'], label='LSB Hits', color='tab:orange', marker='x')
    ax2.tick_params(axis='y', labelcolor='tab:orange')

    # Add a title and legend
    plt.title(f'{benchmark_name} - {sweep_type} Sweep')
    fig.tight_layout()
    
    # Save or show the plot
    plt.savefig(f'./benchmark_data/{benchmark_name}_{sweep_type}_sweep_plot.png', bbox_inches='tight', dpi=300)
    #plt.show()

# Directory containing the CSV files
data_directory = './benchmark_data'

# Iterate through each CSV file in the directory
for file_name in os.listdir(data_directory):
    if file_name.endswith('.csv'):
        # Determine the sweep type from the file name
        if 'IPC' in file_name:
            sweep_type = 'IPC'
        elif 'LSQ' in file_name:
            sweep_type = 'LSQ'
        elif 'ROB' in file_name:
            sweep_type = 'ROB'
        else:
            continue  # Skip files that don't match the pattern
        
        # Plot the data
        file_path = os.path.join(data_directory, file_name)
        plot_benchmark_data(file_path, sweep_type)
