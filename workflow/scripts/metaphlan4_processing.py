import pandas as pd
import numpy as np
import os
import glob
import sys

#functions go here

def process_df(df):
    df = df.drop(["clade_taxid", "coverage"], axis = 1)
    
    # Split the first column and create a new DataFrame
    split_df = df.iloc[:, 0].str.split('|', expand=True)
    
    # Define the column names
    columns = ["domain", "phylum", "class", "order", "family", "genus", "species", "strain"]
    
    # Add any missing columns to split_df
    for i in range(split_df.shape[1], len(columns)):
        split_df[i] = None
    
    # Assign the column names to split_df
    split_df.columns = columns[:split_df.shape[1]]
    
    # Concatenate the split data with the original DataFrame
    df = pd.concat([split_df, df.iloc[:, 1:]], axis=1)
    
    return df


def clean_columns_and_remove_duplicates(filled_df: pd.DataFrame) -> pd.DataFrame:
    # Define the columns to be cleaned
    cols_to_clean = ['domain', 'phylum', 'class', 'order', 'family', 'genus', 'species']

    # Apply the lambda function to each element of the DataFrame
    filled_df[cols_to_clean] = filled_df[cols_to_clean].apply(lambda col: col.map(lambda x: str(x).split('__')[-1] if pd.notnull(x) else x))

    # Rename columns
    filled_df = filled_df.rename(columns={
        'estimated_number_of_reads_from_the_clade': 'reads_from_clade',
        'percentage': 'relative_abundance'
    })

    # Remove duplicates
    filled_df = filled_df.drop_duplicates()

    return filled_df

def extract_filename_and_insert(file_path: str, filled_df: pd.DataFrame) -> pd.DataFrame:
    # Extract the filename from the file path
    file_name = os.path.basename(file_path)
    file_name = "_".join(file_name.split("_")[:-2])
    filled_df.insert(0, 'sample', file_name)
    return filled_df

# Main script starts here

# Check if the correct number of command-line arguments were provided
if len(sys.argv) != 3:
    print("Usage: python metaphlan4_processing.py <input_dir> <output_file>")
    sys.exit(1)

# Get the input directory and output file from the command-line arguments
input_dir = sys.argv[1]
output_file = sys.argv[2]

# Get a list of all txt files in the input directory
file_list = glob.glob(os.path.join(input_dir, '*.txt'))

# Initialize an empty DataFrame to hold all the data
master_df = pd.DataFrame()

# Process each file
for file_path in file_list:
    # Read the file into a DataFrame
    df = pd.read_csv(file_path, sep="\t", skiprows=5)

    # Process the DataFrame
    df = process_df(df)
    df = clean_columns_and_remove_duplicates(df)
    df = extract_filename_and_insert(file_path, df)

    # Append the processed DataFrame to the master DataFrame
    master_df = pd.concat([master_df, df])

# Write the master DataFrame to the output CSV file
master_df.to_csv(output_file, index=False)