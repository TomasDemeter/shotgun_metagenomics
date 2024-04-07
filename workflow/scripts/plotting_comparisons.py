import pandas as pd
import seaborn as sns
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import matplotlib.cm as cm
import matplotlib.colors as mcolors
import numpy as np
import os
import glob
import sys


#######################
###### Functions ######
#######################

def method_comparison_bact_taxa(df, taxa, minreads, relative_abundance):
    if taxa == "species":
        filtered_merged = df[(df["domain"] == "Bacteria")  & (df["reads_from_clade"] > minreads) & (df["relative_abundance"] > relative_abundance) & (df[taxa].notnull())]
    else:
        filtered_merged = df[(df["domain"] == "Bacteria")  & (df["reads_from_clade"] > minreads) & (df[taxa].notnull()) & (df.iloc[:,df.columns.get_loc(taxa)+1].isnull())]

    # Group the data and count the number of rows in each group
    grouped_df = filtered_merged.drop_duplicates().groupby(['sample', 'method']).size().reset_index(name='counts')
    
    # Pivot the data for plotting
    pivot_df = grouped_df.pivot(index='sample', columns='method', values='counts').fillna(0)
    
    method_to_color = {
        'metaphlan4_bbmap': '#C17FDE',
        'metaphlan4_bowtie': '#895B9E',
        'kraken2_bbmap': '#FFB21F',
        'kraken2_bowtie': '#A87614',
        'bracken_bbmap': '#1BA6F2',
        'bracken_bowtie': '#1378B0',
    }
    
    # Create a figure and axis with larger width
    fig, ax = plt.subplots(figsize=(20, 10))  # Increase the width of the figure

    # Plot with smaller bar width
    pivot_df.plot(kind='bar', stacked=False, color=method_to_color, edgecolor = "black", ax=ax, width=0.6)  # Decrease the width of the bars

    # Remove top and right borders
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.xaxis.grid(False)

    # Add more ticks to y-axis
    ax.yaxis.set_major_locator(ticker.MultipleLocator(2)) 

    plt.title(f'{taxa} per sample')
    plt.xlabel('Sample')
    plt.ylabel(f'{taxa} count')

    # Specify the legend position
    plt.legend(loc='upper left')
    
    # Return the figure
    return fig

def common_taxa(df, taxa, minreads, relative_abundance):
    if taxa == "species":
        filtered_merged = df[(df["domain"] == "Bacteria")  & (df["reads_from_clade"] > minreads) & (df["relative_abundance"] > relative_abundance) & (df[taxa].notnull())]
    else:
        filtered_merged = df[(df["domain"] == "Bacteria")  & (df["reads_from_clade"] > minreads) & (df[taxa].notnull()) & (df.iloc[:,df.columns.get_loc(taxa)+1].isnull())]
        
    # Get unique species for each method and sample
    species_per_method_sample = filtered_merged.groupby(['method', 'sample'])[taxa].unique()

    # Find intersection of taxa between different methods in the same sample
    common_taxa_per_sample = {}
    for sample in species_per_method_sample.index.get_level_values('sample').unique():
        taxa_sets = [set(taxa) for taxa in species_per_method_sample.loc[(slice(None), sample)].values]
        taxa_counts = {taxa: sum([taxa in taxa_set for taxa_set in taxa_sets]) for taxa in set.union(*taxa_sets)}
        common_taxa_per_sample[sample] = {taxa for taxa, count in taxa_counts.items() if count >= 6}  # change this to the number of methods

        # Count the number of common taxa for each sample
    common_taxa_counts = {sample: len(taxa) for sample, taxa in common_taxa_per_sample.items()}

    # Create DataFrame for easier plotting
    df_plot = pd.DataFrame(list(common_taxa_counts.items()), columns=['Sample', 'Common Taxa Count'])

    # Generate bar plot
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.bar(df_plot['Sample'], df_plot['Common Taxa Count'], color='#1BA6F2', edgecolor = "black")

    # Remove top and right borders
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.xaxis.grid(False)
    
    plt.title(f'Common {taxa} per Sample (Metaphlan4, Kraken2, Bracken)')
    plt.ylabel(f'Common {taxa} Count')
    plt.xticks(rotation=90)
    
    common_taxa_per_sample_df = pd.DataFrame.from_dict(common_taxa_per_sample, orient='index')
    return fig, common_taxa_per_sample_df

def common_taxa_no_kraken(df, taxa, minreads, relative_abundance):
    if taxa == "species":
        filtered_merged = df[(df["domain"] == "Bacteria")  & (df["reads_from_clade"] > minreads) & (df["relative_abundance"] > relative_abundance) & (df[taxa].notnull())]
    else:
        filtered_merged = df[(df["domain"] == "Bacteria")  & (df["reads_from_clade"] > minreads) & (df[taxa].notnull()) & (df.iloc[:,df.columns.get_loc(taxa)+1].isnull())]

    filtered_merged = filtered_merged[~filtered_merged["method"].str.contains("kraken")]

    # Get unique species for each method and sample
    species_per_method_sample = filtered_merged.groupby(['method', 'sample'])[taxa].unique()

    # Find intersection of taxa between different methods in the same sample
    common_taxa_per_sample = {}
    for sample in species_per_method_sample.index.get_level_values('sample').unique():
        taxa_sets = [set(taxa) for taxa in species_per_method_sample.loc[(slice(None), sample)].values]
        taxa_counts = {taxa: sum([taxa in taxa_set for taxa_set in taxa_sets]) for taxa in set.union(*taxa_sets)}
        common_taxa_per_sample[sample] = {taxa for taxa, count in taxa_counts.items() if count == 4 }  # change this to the number of methods

        # Count the number of common taxa for each sample
    common_taxa_counts = {sample: len(taxa) for sample, taxa in common_taxa_per_sample.items()}

    # Create DataFrame for easier plotting
    df_plot = pd.DataFrame(list(common_taxa_counts.items()), columns=['Sample', 'Common Taxa Count'])

    # Generate bar plot
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.bar(df_plot['Sample'], df_plot['Common Taxa Count'], color='#1BA6F2', edgecolor = "black")

    # Remove top and right borders
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.xaxis.grid(False)
    
    plt.title(f'Common {taxa} per Sample (Metaphlan4, Bracken)')
    plt.ylabel(f'Common {taxa} Count')
    plt.xticks(rotation=90)
    
    common_taxa_per_sample_df = pd.DataFrame.from_dict(common_taxa_per_sample, orient='index')
    return fig, common_taxa_per_sample_df


###################################
########## Main script ############
###################################

# Get the input directory and output file from the command-line arguments
input_dir = sys.argv[1]
output_file = sys.argv[2]
minreads = int(sys.argv[3])
relative_abundance = float(sys.argv[4])

rank_names = ["species", "genus", "family"]

# Create a list of tuples containing the dataframes and their corresponding names
dataframes = [
    (pd.read_csv(os.path.join(input_dir, "Kraken2_Bowtie_report.csv")), "kraken2_bowtie"),
    (pd.read_csv(os.path.join(input_dir, "Kraken2_BBmap_report.csv")), "kraken2_bbmap"),
    (pd.read_csv(os.path.join(input_dir, "Metaphlan4_Bowtie_report.csv")), "metaphlan4_bowtie"),
    (pd.read_csv(os.path.join(input_dir, "Metaphlan4_BBmap_report.csv")), "metaphlan4_bbmap"),
    (pd.read_csv(os.path.join(input_dir, "Bracken_Bowtie_report.csv")), "bracken_bowtie"),
    (pd.read_csv(os.path.join(input_dir, "Bracken_BBmap_report.csv")), "bracken_bbmap"),
]

### COMPARISON OF NUMBER OF DIFFERENT CLADES DETECTED BY DIFFERENT METHODS ####
for df, name in dataframes:
    df['method'] = name

dfs = [df for df, name in dataframes]

merged_df = pd.concat(dfs, ignore_index=True).drop_duplicates()

for rank in rank_names:
    # Call the function with the rank name
    plot = method_comparison_bact_taxa(merged_df, rank, minreads, relative_abundance)
    plot.savefig(os.path.join(output_file, f"{rank}_method_comparison.png"), dpi=300, bbox_inches='tight')
    plt.close(plot)

    fig, df = common_taxa(merged_df, rank, minreads, relative_abundance)
    fig.savefig(os.path.join(output_file, f"{rank}_common_withKraken.png"), dpi=300, bbox_inches='tight')
    df.to_csv(os.path.join(output_file, f"{rank}_common_withKraken.csv"), index=True)
    plt.close(fig)

    fig, df = common_taxa_no_kraken(merged_df, rank, minreads, relative_abundance)
    fig.savefig(os.path.join(output_file, f"{rank}_withoutKraken.png"), dpi=300, bbox_inches='tight')
    df.to_csv(os.path.join(output_file, f"{rank}_withoutKraken.csv"), index=True)
    plt.close(fig)