import os
import pandas as pd
import argparse

def process_files(dir_path):
    file_paths = [os.path.join(dir_path, file) for file in os.listdir(dir_path) if file.endswith('.txt')]
    dfs = []
    for file_path in file_paths:
        df = pd.read_csv(file_path, delimiter='\t', header = None)
        base_name = os.path.basename(file_path)
        parts = base_name.split('_')
        sample_name = '_'.join(parts[:4])
        df['sample'] = sample_name
        dfs.append(df)
    df_concat = pd.concat(dfs)
    df_concat = df_concat.rename(columns={'#clade_name': 'clade_name'})
    df_concat.columns = ["clade_name", "estimated_number_of_reads_from_the_clade", "relative_abundance", "sample"]
    df_concat = df_concat.iloc[:,0:6]
    return df_concat

def shift_row(df):
    # Create a subset of the DataFrame where the first column is 'Bacteria'
    subset = df[df["Domain"] == 'Bacteria'].copy()

    # Drop the last column of the subset
    subset.drop(subset.columns[-1], axis=1, inplace=True)

    # Insert a column with None values at index 1
    subset.insert(1, '', None)
    subset.columns = ["Domain", "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"]

    return subset

def process_dataframe(df, shift_row):
    split_df = df['clade_name'].str.split('|', expand=True)
    for col in split_df.columns:
        split_df[col] = split_df[col].str.split('__', expand=True)[1]

    # Filter rows where the first column is Bacteria, Eukaryota, or unclassified
    split_df = split_df[split_df[0].isin(['Bacteria', 'Eukaryota', 'unclassified'])]
    split_df.columns = ["Domain", "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"]
    shift_bact = shift_row(split_df)
    split_df = split_df[split_df["Domain"] != "Bacteria"]
    split_df = pd.concat([split_df, shift_bact])

    split_df.reset_index(drop=True, inplace=True)
    df.reset_index(drop=True, inplace=True)
    df = df.join(split_df)
    df = df.drop(columns=['clade_name'])
    column_order = ['sample','Domain', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species', 'relative_abundance', 'estimated_number_of_reads_from_the_clade']
    df = df.reindex(columns=column_order)

    return df

def main():
    parser = argparse.ArgumentParser(description='Process files.')
    parser.add_argument('dir_path', type=str, help='Directory path containing the files')
    parser.add_argument('--delimiter', type=str, default=',', help='Delimiter for the output CSV file')
    args = parser.parse_args()
    df = process_files(args.dir_path)
    df2 = process_dataframe(df, shift_row)

    # Save the DataFrame to a CSV file
    output_file = os.path.join(args.dir_path, 'kraken2_output_merged.csv')
    df2.to_csv(output_file, index=False, sep=args.delimiter)

if __name__ == "__main__":
    main()