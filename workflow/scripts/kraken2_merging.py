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

def shift_values(df):
    # Create a mask where 'Domain' column is 'Bacteria'
    mask = df['Domain'] == 'Bacteria'
    
    # Select rows where mask is True and shift values to the right
    df.loc[mask, "Kingdom":"Species"] = df.loc[mask, "Domain":"Species"].shift(periods=1, axis="columns")
    
    # Fill 'Domain' with 'Bacteria' and 'Kingdom' with 'None' for the rows where mask is True
    df.loc[mask, 'Domain'] = 'Bacteria'
    df.loc[mask, 'Kingdom'] = None
    return df

def process_dataframe(df):
    taxa_columns = ["Domain", "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"]
    column_order = ['sample','Domain', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species', 'relative_abundance', 'estimated_number_of_reads_from_the_clade']

    df[taxa_columns] = df['clade_name'].str.split('|', expand=True)
    for col in df[taxa_columns]:
        df[col] = df[col].str.split('__', expand=True)[1]
    df = df.drop(columns=['clade_name'])
    df = shift_values(df)
    df = df.reindex(columns=column_order)
    return df

def main():
    parser = argparse.ArgumentParser(description='Process files.')
    parser.add_argument('dir_path', type=str, help='Directory path containing the files')
    parser.add_argument('output_dir', type=str, help='Output directory for the CSV file')
    parser.add_argument('output_file', type=str, help='Name of the output CSV file')
    parser.add_argument('--delimiter', type=str, default=',', help='Delimiter for the output CSV file')
    args = parser.parse_args()
    df = process_files(args.dir_path)
    df2 = process_dataframe(df)

    # Save the DataFrame to a CSV file
    output_file = os.path.join(args.output_dir, args.output_file)
    df2.to_csv(output_file, index=False, sep=args.delimiter)

if __name__ == "__main__":
    main()