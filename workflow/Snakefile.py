########################################################
# Snakemake pipeline for shotgun metagenomics analysis #
########################################################
'''
snakemake -s Snakefile.py --use-conda --rerun-incomplete --cluster "sbatch --account=kouyos.virology.uzh --partition=standard --time=24:00:00 --cpus-per-task=56 --mem=200G" --jobs 4
snakemake -s Snakefile.py --use-conda --rerun-incomplete --keep-going --cluster "sbatch --account=kouyos.virology.uzh --partition=standard --time=5-00:00:00 --cpus-per-task=56 --mem=200G" --jobs 4
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
MULTIQC = RESULT_DIR + "MultiQC/multiqc_report.html"

#########
# rules #
#########
include: "rules/fastp.smk"
include: "rules/bowtie2.smk"
include: "rules/bbsuite.smk"
include: "rules/multiqc.smk"

############
# Pipeline #
############
rule all:
    input:
        MULTIQC
    message:
        "Metagenomic pipeline run complete!"
