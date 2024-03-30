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


# functions
def plot_relative_abundance(df, num_reads, method):
    # Filter and group the DataFrame
    filtered_df = df[df["domain"].isin(["Bacteria", "Eukaryota", "unclassified"]) & df["domain"].notnull() & (df["reads_from_clade"] > num_reads) ]
    filtered_df = filtered_df.groupby(['sample', "domain"])['relative_abundance'].sum().reset_index()

    # Pivot and normalize the DataFrame
    filtered_df = filtered_df.pivot(index='sample', columns="domain", values='relative_abundance')
    filtered_df = filtered_df.apply(lambda row: 100. * row / row.sum(), axis=1)
    filtered_df = filtered_df.fillna(0)

    # Create a colormap
    cmap = matplotlib.colormaps.get_cmap('tab20c')  
    
    # Generate colors from the colormap
    colors = cmap(np.linspace(0, 1, len(filtered_df.columns)))

    # Create a figure and axis with larger width
    fig, ax = plt.subplots(figsize=(20, 10))  # Increase the width of the figure

    # Plot with smaller bar width
    filtered_df.plot(kind='bar', stacked=True, color=colors, edgecolor = "black", ax=ax, width=0.6)  # Decrease the width of the bars

    # Remove top and right borders
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.xaxis.grid(False)

    # Add more ticks to y-axis
    ax.yaxis.set_major_locator(ticker.MultipleLocator(10))  # Change the number based on your specific needs

    plt.title(f'Relative Abundance per Sample ({method})')
    plt.xlabel('Sample')
    plt.ylabel('Relative Abundance')
    plt.legend(title="domain", bbox_to_anchor=(1.05, 1), loc='upper left')
    return fig

def plot_relative_abundance_bacteria(df, column, min_reads, method):
    filtered_df = df[(df["domain"] == "Bacteria") & (df[column].notnull()) & (df["reads_from_clade"] > min_reads) ]
    # Aggregate the data
    filtered_df = filtered_df.groupby(['sample', column])['relative_abundance'].sum().reset_index()
    filtered_df = filtered_df.pivot(index='sample', columns=column, values='relative_abundance')
    filtered_df = filtered_df.apply(lambda row: 100. * row / row.sum(), axis=1)
    # Fill NaN values with 0
    filtered_df = filtered_df.fillna(0)
    
    # Create a colormap
    cmap = matplotlib.colormaps.get_cmap('tab20c')  
    
    # Generate colors from the colormap
    colors = cmap(np.linspace(0, 1, len(filtered_df.columns)))

    # Create a figure and axis with larger width
    fig, ax = plt.subplots(figsize=(20, 10))  # Increase the width of the figure

    # Plot with smaller bar width
    filtered_df.plot(kind='bar', stacked=True, color=colors, edgecolor = "black", ax=ax, width=0.6)  # Decrease the width of the bars

    # Remove top and right borders
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.xaxis.grid(False)

    # Add more ticks to y-axis
    ax.yaxis.set_major_locator(ticker.MultipleLocator(10))  # Change the number based on your specific needs

    plt.title(f'Relative Abundance per Sample ({method})')
    plt.xlabel('Sample')
    plt.ylabel('Relative Abundance')
    plt.legend(title=column, bbox_to_anchor=(1.05, 1), loc='upper left')
    return fig

def plot_number_of_reads(df, column, min_reads):
    # Reset the index of the DataFrame
    df = df[(df["domain"] == "Bacteria") & (df[column].notnull()) & (df["reads_from_clade"] > min_reads) ].drop_duplicates().reset_index(drop=True)
    df = df.reset_index()

    # Get the unique method name from the 'method' column
    method = df['method'].unique()[0]

    # Create a figure and axis with larger width
    fig, ax = plt.subplots(figsize=(10, 0.5*len(df)))  # Adjust the height of the figure based on the number of rows in the dataframe

    # Create a horizontal bar plot colored by sample
    sns.barplot(x='reads_from_clade', y='index', hue='sample', data=df, orient='h', ax=ax)

    # Remove top and right borders
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.xaxis.grid(False)

    # Set the title of the plot using the method name
    plt.title(f'Reads per species per sample ({method})')
    plt.xlabel('Number of reads')
    plt.ylabel('')

    # Set the y-ticks to the index of the DataFrame
    ax.set_yticks(df.index)

    # Replace the y-tick labels with the species names
    ax.set_yticklabels(df['species'])

    # Specify the legend position
    plt.legend(loc='lower right')

    # Return the figure
    return fig

def plot_number_of_reads_log(df, column, min_reads):
    # Reset the index of the DataFrame
    df = df[(df["domain"] == "Bacteria") & (df[column].notnull()) & (df["reads_from_clade"] > min_reads) ].drop_duplicates().reset_index(drop=True)
    df = df.reset_index()

    # Get the unique method name from the 'method' column
    method = df['method'].unique()[0]

    # Create a figure and axis with larger width
    fig, ax = plt.subplots(figsize=(10, 0.5*len(df)))  # Adjust the height of the figure based on the number of rows in the dataframe

    # Create a horizontal bar plot colored by sample
    sns.barplot(x='reads_from_clade', y='index', hue='sample', data=df, orient='h', ax=ax)

    # Remove top and right borders
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.xaxis.grid(False)

    # Set the title of the plot using the method name
    plt.title(f'Reads per species per sample ({method})')
    plt.xlabel('Log10 number of reads')
    plt.ylabel('')

    # Set the y-ticks to the index of the DataFrame
    ax.set_yticks(df.index)

    # Replace the y-tick labels with the species names
    ax.set_yticklabels(df['species'])

    # Set the x-axis to a logarithmic scale
    ax.set_xscale('log')
    ax.xaxis.set_major_locator(ticker.LogLocator(base=10))
    ax.xaxis.set_major_formatter(ticker.LogFormatter(base=10))

    # Specify the legend position
    plt.legend(loc='lower right')

    # Return the figure
    return fig

def method_comparison_bact_taxa(df, taxa, minreads):
    if taxa == "species":
        filtered_merged = df[(df["domain"] == "Bacteria")  & (df["reads_from_clade"] > minreads) & (df[taxa].notnull())]
    else:
        filtered_merged = df[(df["domain"] == "Bacteria")  & (df["reads_from_clade"] > minreads) & (df[taxa].notnull()) & (df.iloc[:,df.columns.get_loc(taxa)+1].isnull())]

    # Group the data and count the number of rows in each group
    grouped_df = filtered_merged.drop_duplicates().groupby(['sample', 'method']).size().reset_index(name='counts')
    
    # Pivot the data for plotting
    pivot_df = grouped_df.pivot(index='sample', columns='method', values='counts').fillna(0)
    
    # Create a colormap
    cmap = matplotlib.colormaps.get_cmap('tab20c')

    # Generate colors from the colormap
    colors = cmap(np.linspace(0, 1, len(pivot_df.columns)))

    # Create a figure and axis with larger width
    fig, ax = plt.subplots(figsize=(20, 10))  # Increase the width of the figure

    # Plot with smaller bar width
    pivot_df.plot(kind='bar', stacked=False, color=colors, edgecolor = "black", ax=ax, width=0.6)  # Decrease the width of the bars

    # Remove top and right borders
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.xaxis.grid(False)

    # Add more ticks to y-axis
    ax.yaxis.set_major_locator(ticker.MultipleLocator(2)) 

    plt.title(f' {taxa} per sample')
    plt.xlabel('Sample')
    plt.ylabel(f'{taxa} count')

    # Specify the legend position
    plt.legend(loc='upper left')

    # Return the figure
    return fig

def plot_number_of_reads_log(df, column, min_reads):
    # Reset the index of the DataFrame
    df = df[(df["domain"] == "Bacteria") & (df[column].notnull()) & (df["reads_from_clade"] > min_reads) & (df["relative_abundance"] > 0.1)].drop_duplicates().reset_index(drop=True)
    df = df.reset_index()

    # Get the unique method name from the 'method' column
    method = df['method'].unique()[0]

    # Create a figure and axis with larger width
    fig, ax = plt.subplots(figsize=(10, 0.5*len(df)))  # Adjust the height of the figure based on the number of rows in the dataframe

    # Create a horizontal bar plot colored by sample
    sns.barplot(x='reads_from_clade', y='index', hue='sample', data=df, orient='h', ax=ax)

    # Remove top and right borders
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.xaxis.grid(False)

    # Set the title of the plot using the method name
    plt.title(f'Reads per species per sample ({method})')
    plt.xlabel('Log10 number of reads')
    plt.ylabel('')

    # Set the y-ticks to the index of the DataFrame
    ax.set_yticks(df.index)

    # Replace the y-tick labels with the species names
    ax.set_yticklabels(df['species'])

    # Set the x-axis to a logarithmic scale
    ax.set_xscale('log')
    ax.xaxis.set_major_locator(ticker.LogLocator(base=10))
    ax.xaxis.set_major_formatter(ticker.LogFormatter(base=10))

    # Specify the legend position
    plt.legend(loc='lower right')

    # Return the figure
    return fig

def plot_number_of_reads(df, column, min_reads):
    # Reset the index of the DataFrame
    df = df[(df["domain"] == "Bacteria") & (df[column].notnull()) & (df["reads_from_clade"] > min_reads) & (df["relative_abundance"] > 0.1)].drop_duplicates().reset_index(drop=True)
    df = df.reset_index()

    # Get the unique method name from the 'method' column
    method = df['method'].unique()[0]

    # Create a figure and axis with larger width
    fig, ax = plt.subplots(figsize=(10, 0.5*len(df)))  # Adjust the height of the figure based on the number of rows in the dataframe

    # Create a horizontal bar plot colored by sample
    sns.barplot(x='reads_from_clade', y='index', hue='sample', data=df, orient='h', ax=ax)

    # Remove top and right borders
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.xaxis.grid(False)

    # Set the title of the plot using the method name
    plt.title(f'Reads per species per sample ({method})')
    plt.xlabel('Number of reads')
    plt.ylabel('')

    # Set the y-ticks to the index of the DataFrame
    ax.set_yticks(df.index)

    # Replace the y-tick labels with the species names
    ax.set_yticklabels(df['species'])

    # Specify the legend position
    plt.legend(loc='lower right')

    # Return the figure
    return fig


###################################
########## Main script ############
###################################

# Get the input directory and output file from the command-line arguments
input_dir = sys.argv[1]
output_file = sys.argv[2]
minreads = int(sys.argv[3])

# Create a list of tuples containing the dataframes and their corresponding names
dataframes = [
    (pd.read_csv(os.path.join(input_dir, "Kraken2_Bowtie_report.csv")), "kraken2_bowtie"),
    (pd.read_csv(os.path.join(input_dir, "Kraken2_BBmap_report.csv")), "kraken2_bbmap"),
    (pd.read_csv(os.path.join(input_dir, "Metaphlan4_Bowtie_report.csv")), "metaphlan4_bowtie"),
    (pd.read_csv(os.path.join(input_dir, "Metaphlan4_BBmap_report.csv")), "metaphlan4_bbmap"),
]

# Use separate loops to iterate over the dataframes and the plot functions
for df, name in dataframes:
    # Call plot_relative_abundance function
    plot = plot_relative_abundance(df, minreads, f"{name.split('_')[1]}, {name.split('_')[0]}")
    plot.savefig(os.path.join(output_file, f"{name}_domains.png"), dpi=300, bbox_inches='tight')
    plt.close(plot)


### GET RELATIVE ABUNDANCES OF DIFFERENT CLADES FOR EACH METHOD ###
# Create a list of tuples containing the plot functions that require an extra argument, the taxonomic ranks, and the corresponding file names
    
rank_names = ["species", "genus", "family"]

for df, name in dataframes:
    for rank in rank_names:
        # Call the function with the extra argument
        plot = plot_relative_abundance_bacteria(df, rank, minreads, f"{name.split('_')[1]}, {name.split('_')[0]}")
        plot.savefig(os.path.join(output_file, f"{name}_{rank}.png"), dpi=300, bbox_inches='tight')
        plt.close(plot)


### COMPARISON OF NUMBER OF DIFFERENT CLADES DETECTED BY DIFFERENT METHODS ####
for df, name in dataframes:
    df['method'] = name

dfs = [df for df, name in dataframes]

merged_df = pd.concat(dfs, ignore_index=True).drop_duplicates()

for rank in rank_names:
    # Call the function with the rank name
    plot = method_comparison_bact_taxa(merged_df, rank, minreads)
    plot.savefig(os.path.join(output_file, f"{rank}_method_comparison.png"), dpi=300, bbox_inches='tight')
    plt.close(plot)

    plot = plot_number_of_reads(merged_df, rank, minreads)
    plot.savefig(os.path.join(output_file, f"{rank}_number_of_reads.png"), dpi=300, bbox_inches='tight')
    plt.close(plot)

    plot = plot_number_of_reads_log(merged_df, rank, minreads)
    plot.savefig(os.path.join(output_file, f"{rank}_number_of_reads_log.png"), dpi=300, bbox_inches='tight')
    plt.close(plot)
