
########################################################
# Snakemake pipeline for shotgun metagenomics analysis #
########################################################


########################################
# to run the pipeline use this command #
########################################
'''
snakemake -s Snakefile.py --profile slurm_snakemake
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
samples = pd.read_csv(samplefile, dtype = str, index_col = 0)
SAMPLES = samples.index.tolist()

###################
# Desired outputs #
###################
MULTIQC         = RESULT_DIR + "MultiQC/multiqc_report.html"
METAPHLAN       = RESULT_DIR + "merged_csv_files/Metaphlan4_Bowtie2_merged.csv"
METAPHLAN_BBMAP = RESULT_DIR + "merged_csv_files/Metaphlan4_Bbmap_merged.csv"
KRAKEN2         = RESULT_DIR + "merged_csv_files/Kraken2_Bowtie2_merged.csv"
KRAKEN2_BBMAP   = RESULT_DIR + "merged_csv_files/Kraken2_Bbmap_merged.csv"
STRAINPHLAN     = RESULT_DIR + "StrainPhlAn/alignments/RAxML_bestTree.s__GCA_000146485.StrainPhlAn4.tre"

#########
# rules #
#########
include: "rules/fastp.smk"
include: "rules/bowtie2.smk"
include: "rules/bbsuite.smk"
include: "rules/fastqc.smk"
include: "rules/multiqc.smk"
include: "rules/metaphlan.smk"
include: "rules/metaphlan_bbmap.smk"
include: "rules/kraken2.smk"
include: "rules/kraken2_bbmap.smk"
include: "rules/StrainPhlAn.smk"

############
# Pipeline #
############
rule all:
    input:
        MULTIQC,
        METAPHLAN,
        METAPHLAN_BBMAP,
        KRAKEN2,
        KRAKEN2_BBMAP,
        STRAINPHLAN
    message:
        "Metagenomic pipeline run complete!"