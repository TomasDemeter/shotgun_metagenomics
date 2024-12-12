
########################################################
# Snakemake pipeline for shotgun metagenomics analysis #
########################################################


########################################
# to run the pipeline use this command #
########################################
'''
snakemake -s Snakefile.py --workflow-profile profiles/shotgun_pipeline/  -n
snakemake -s Snakefile.py --profile profiles/default -n
'''

####################
# Python pacakages #
####################
import pandas as pd

#################
# Configuration #
#################
configfile: "../config/config.yaml" # where to find parameters
WORKING_DIR = config["working_dir"]
RESULT_DIR  = config["result_dir"]
samplefile  = config["refs"]["samples"]

##########################
# Samples and conditions #
##########################
# create lists containing the sample names and conditions
samples = pd.read_csv(samplefile, dtype = str, index_col = 0, header = None)
SAMPLES = samples.index.tolist()

###################
# Desired outputs #
###################
MULTIQC         = RESULT_DIR + "MultiQC/multiqc_report.html"
METAPHLAN       = RESULT_DIR + "Kraken_Bracken_Metaphlan_output/Metaphlan4_Bowtie_report.csv"
KRAKEN2         = RESULT_DIR + "Kraken_Bracken_Metaphlan_output/Kraken2_Bowtie_report.csv"
BRACKEN         = RESULT_DIR + "Kraken_Bracken_Metaphlan_output/Bracken_Bowtie_report.csv"
PLOTS           = RESULT_DIR + "Kraken_Bracken_Metaphlan_output/figures/kraken2_bowtie_domains.png"
PHYLOSEQ        = RESULT_DIR + "Phyloseq/Metaphlan4_Bowtie_report.rds"
STRAINPHLAN     = RESULT_DIR + "StrainPhlAn/alignments/print_clades_only.tsv"

#########
# rules #
#########
include: "rules/download_human_genome.smk"
include: "rules/fastp.smk"
include: "rules/bowtie2.smk"
include: "rules/fastqc.smk"
include: "rules/multiqc.smk"
include: "rules/metaphlan_build.smk"
include: "rules/metaphlan.smk"
include: "rules/kraken2_build.smk"
include: "rules/kraken2.smk"
include: "rules/strainphlan.smk"
include: "rules/bracken_build.smk"
include: "rules/bracken.smk"
include: "rules/plotting_kraken_metaphlan_bracken.smk"
include: "rules/create_phyloseq.smk"

############
# Pipeline #
############
rule all:
    input:
        MULTIQC,
        METAPHLAN,
        KRAKEN2,
        BRACKEN,
        PLOTS,
        PHYLOSEQ,
        STRAINPHLAN,
        get_all_trees,
        get_all_visualizations
    message:
        "Shotgun metagenomic pipeline run complete!"