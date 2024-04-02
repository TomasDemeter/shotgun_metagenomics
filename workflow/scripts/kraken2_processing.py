import pandas as pd
import numpy as np
import os
import glob
import sys

#functions go here

def process_df(df):
    df = df.drop([2,4], axis =1 )
    df.columns = ['relative_abundance', 'reads_from_clade', 'rank', 'name']

    # Remove rows where 'rank' ends with a number
    df = df[~df['rank'].str[-1].str.isdigit()]

    df = df[~df['rank'].isin(['U', 'R'])].reset_index()
    new_df = pd.DataFrame(columns=['D', 'K', 'P', 'C', 'O', 'F', 'G', 'S', 'relative_abundance', 'reads_from_clade'])

    for index, row in df.iterrows():
        new_row = pd.Series([np.nan]*8 + [row['relative_abundance'], row['reads_from_clade']], index=new_df.columns).astype(object)
        new_row[row['rank']] = row['name']
        new_df = pd.concat([new_df, pd.DataFrame(new_row).T])

    new_df.drop(['K'], axis=1, inplace=True)
    new_df.columns = ['domain', 'phylum', 'class', 'order', 'family', 'genus', 'species', 'relative_abundance', 'reads_from_clade']
    new_df = new_df.drop_duplicates()

    return pd.DataFrame(new_df)

def fill_and_reorder_df(new_df: pd.DataFrame) -> pd.DataFrame:
    # create new df with columns that needs to be filled
    sub_df = new_df.iloc[:,:-2]
    # save the column names that need to be filled
    cols = sub_df.columns

    # create new df to store the filled columns
    filled_df = pd.DataFrame()

    # iterate over the columns in reverse order
    for i in cols[::-1]:
        # go row by row in the column and check whether that row in sub_df has only NaN values
        for j in range(len(sub_df)):
            # check if the row in the dataframe has nothing but NaN values
            if sub_df.iloc[j].isna().all():
                # if so, fill the column with the previous value in that column
                sub_df[i].iloc[j] = sub_df[i].ffill().iloc[j]

        # append the filled column to the filled_df
        filled_df[i] = sub_df[i]
        # drop the filled column from the sub_df
        sub_df.drop(i, axis=1, inplace=True)

    # Reverse the column order in filled_df to match original order
    filled_df = filled_df[cols]

    # Append the last two columns to the filled_df
    filled_df = pd.concat([filled_df, new_df.iloc[:,-2:]], axis=1)

    # Remove leading and trailing spaces from each value in all the columns
    filled_df = filled_df.applymap(lambda x: x.strip() if isinstance(x, str) else x)

    return filled_df

def clean_columns_and_remove_duplicates(filled_df: pd.DataFrame) -> pd.DataFrame:
    # Define the columns to be cleaned
    cols_to_clean = ['domain', 'phylum', 'class', 'order', 'family', 'genus', 'species']

    # Apply the lambda function to each element of the DataFrame
    filled_df[cols_to_clean] = filled_df[cols_to_clean].apply(lambda col: col.map(lambda x: str(x).split('__')[-1] if pd.notnull(x) else x))

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
    print("Usage: python kraken2_processing.py <input_dir> <output_file>")
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
    # Check if the file is empty
    if os.path.getsize(file_path) > 0:
        # Read the file into a DataFrame
        df = pd.read_csv(file_path, delimiter = "\t", header=None)
        
        # Process the DataFrame
        df = process_df(df)
        df = fill_and_reorder_df(df)
        df = clean_columns_and_remove_duplicates(df)
        df = extract_filename_and_insert(file_path, df)

        # Append the processed DataFrame to the master DataFrame
        master_df = pd.concat([master_df, df])
    else:
        print(f"File is empty: {file_path}")

# Write the master DataFrame to the output CSV file
master_df.to_csv(output_file, index=False)