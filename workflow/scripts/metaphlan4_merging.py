import os
import pandas as pd
import argparse

def process_files(dir_path):
    file_paths = [os.path.join(dir_path, file) for file in os.listdir(dir_path) if file.endswith('.txt')]
    dfs = []
    for file_path in file_paths:
        skip_rows = 5
        df = pd.read_csv(file_path, delimiter='\t', skiprows=skip_rows)
        base_name = os.path.basename(file_path)
        parts = base_name.split('_')
        sample_name = '_'.join(parts[:4])
        df['sample'] = sample_name
        dfs.append(df)
    df_concat = pd.concat(dfs)
    df_concat = df_concat.rename(columns={'#clade_name': 'clade_name'})
    df_concat = df_concat.iloc[:,0:6]
    return df_concat

def metaphlan_reformating(df):
    taxa_columns = ["Domain", "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"]
    all_columns = ['relative_abundance', 'estimated_number_of_reads_from_the_clade', 'sample','Domain', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species']
    column_order = ['sample','Domain', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species', 'relative_abundance', 'estimated_number_of_reads_from_the_clade']
    
    
    df[taxa_columns] = df['clade_name'].str.split('|', expand=True)
    for col in df[taxa_columns]:
        df[col] = df[col].str.split('__', expand=True)[1]
    df = df.drop(columns=['clade_name', 'clade_taxid', 'coverage', 'Species'])
    df.columns = all_columns
    df["Kingdom"] = None
    df = df.reindex(columns=column_order)
    return df

def main():
    parser = argparse.ArgumentParser(description='Process files.')
    parser.add_argument('dir_path', type=str, help='Directory path containing the files')
    parser.add_argument('--delimiter', type=str, default=',', help='Delimiter for the output CSV file')
    args = parser.parse_args()
    df = process_files(args.dir_path)
    df2 = metaphlan_reformating(df)

    output_file = os.path.join(args.dir_path, 'metaphlan_output_merged.csv')
    df2.to_csv(output_file, index=False, sep=args.delimiter)

if __name__ == "__main__":
    main()