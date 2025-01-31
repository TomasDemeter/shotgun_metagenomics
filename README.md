# Shotgun Metagenomics Analysis Pipeline

## Overview
This Snakemake pipeline is designed for comprehensive shotgun metagenomics analysis. It processes raw sequencing data through various tools for quality control, taxonomic classification, and visualization. It automatically downlaods neccesary databases and genomic files without additional input from user. 

## Features
- Quality control and preprocessing of raw sequencing data
- Human genome contamination removal
- Taxonomic classification using multiple tools (Kraken2, MetaPhlAn4, Bracken)
- Strain-level analysis with StrainPhlAn
- Quality reporting with FastQC and MultiQC
- Visualization of taxonomic profiles
- Integration with phyloseq for downstream analysis

## Prerequisites
- Snakemake
- Python packages:
  - pandas
- Analysis tools:
  - FastQC
  - fastp
  - Bowtie2
  - MetaPhlAn4
  - Kraken2
  - Bracken
  - StrainPhlAn
  - MultiQC

## Configuration
The pipeline requires a configuration file (`config.yaml`) that specifies:
- Working directory
- Results directory
- Sample information file path

## Input
- Sample information file (CSV format with sample names)
- Raw sequencing data (FASTQ files)

## Output
The pipeline generates the following main outputs:

1. Quality Control
   - MultiQC report (`MultiQC/multiqc_report.html`)
   - FastQC reports
   - Cleaned and filtered reads

2. Taxonomic Classification
   - MetaPhlAn4 results (`Kraken_Bracken_Metaphlan_output/Metaphlan4_Bowtie_report.csv`)
   - Kraken2 results (`Kraken_Bracken_Metaphlan_output/Kraken2_Bowtie_report.csv`)
   - Bracken results (`Kraken_Bracken_Metaphlan_output/Bracken_Bowtie_report.csv`)

3. Visualization
   - Taxonomic profile plots (`Kraken_Bracken_Metaphlan_output/figures/`)
   - Phyloseq object (`Phyloseq/Metaphlan4_Bowtie_report.rds`)

4. Strain Analysis
   - StrainPhlAn results (`StrainPhlAn/alignments/print_clades_only.tsv`)
   - Strain-level phylogenetic trees

## Usage

### Running on the SIT slurm cluster
```bash
conda activate snakemake
cd workflow/
snakemake -s Snakefile.py --workflow-profile ./profiles/shotgun_pipeline/ -n
```

### Running Locally

```bash
conda activate snakemake
cd workflow/
snakemake -s Snakefile.py --profile ./profiles/default -n 
```

### Execution
Remove the `-n` flag from the above commands to execute the pipeline.

## Pipeline Steps
1. Download and index human genome for contamination removal
2. Quality control with fastp
3. Human read removal with Bowtie2
4. Quality assessment with FastQC
5. Build and run MetaPhlAn4
6. Build and run Kraken2
7. Build and run Bracken
8. Generate taxonomic profiles and visualizations
9. Create Phyloseq object for downstream analysis
10. Perform strain-level analysis with StrainPhlAn
