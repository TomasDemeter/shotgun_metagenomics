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

def main():
    parser = argparse.ArgumentParser(description='Process files.')
    parser.add_argument('dir_path', type=str, help='Directory path containing the files')
    parser.add_argument('--delimiter', type=str, default=',', help='Delimiter for the output CSV file')
    args = parser.parse_args()
    df = process_files(args.dir_path)
    output_file = os.path.join(args.dir_path, 'metaphlan_output_merged.csv')
    df.to_csv(output_file, index=False, sep=args.delimiter)

if __name__ == "__main__":
    main()