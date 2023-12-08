import pandas as pd
import glob
import os
import sys

def merge_files(directory):
    # Get a list of all txt files in the directory
    files = glob.glob(os.path.join(directory, "*.txt"))
    
    # Initialize an empty DataFrame
    merged_df = pd.DataFrame()
    
    # Loop over the files
    for file in files:
        # Extract part of the filename
        part_of_filename = "_".join(file.split('/')[-1].split('_')[:-2])
        
        # Read the txt file into a DataFrame with specified column names
        df = pd.read_csv(file, sep="\t", header=None, names=['clade', part_of_filename])
        
        # Merge the DataFrame into the main DataFrame
        if merged_df.empty:
            merged_df = df
        else:
            merged_df = pd.merge(merged_df, df, on='clade', how='outer')
    
    # Replace NaN values with 0
    merged_df.fillna(0, inplace=True)
    
    # Save the merged DataFrame to a CSV file
    merged_df.to_csv(os.path.join(directory, 'merged_kraken.csv'), index=False)

if __name__ == "__main__":
    # Check if directory path is provided as command-line argument
    if len(sys.argv) != 2:
        print("Usage: python script.py <directory_path>")
        sys.exit(1)

    # Get the directory path from the command-line argument
    directory_path = sys.argv[1]