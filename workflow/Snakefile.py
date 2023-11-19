########################################################
# Snakemake pipeline for shotgun metagenomics analysis #
########################################################

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
MULTIQC = RESULT_DIR + "MultiQC/multiqc_report.html"

#########
# rules #
#########
include: "rules/bbsuite.smk"
include: "rules/fastp.smk"
include: "rules/bowtie2.smk"
include: "rules/multiqc.smk"

############
# Pipeline #
############
rule all:
    input:
        MULTIQC
    message:
        "Metagenomic pipeline run complete!"