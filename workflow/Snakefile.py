########################################################
# Snakemake pipeline for shotgun metagenomics analysis #
########################################################
'''
snakemake -s Snakefile.py --use-conda --rerun-incomplete --keep-going --cluster "sbatch --account=kouyos.virology.uzh --partition=standard --time=5-00:00:00 --cpus-per-task=32 --mem=100G --mail-type=BEGIN,FAIL,END --mail-user=tomas.demeter@uzh.ch" --jobs 8

snakemake -s Snakefile.py --use-conda --rerun-incomplete --keep-going --cluster "sbatch --account=kouyos.virology.uzh --partition=standard --time=24:00:00 --cpus-per-task=32 --mem=100G --mail-type=BEGIN,FAIL,END --mail-user=tomas.demeter@uzh.ch" --jobs 8

snakemake -s Snakefile.py --use-conda --rerun-incomplete --keep-going --cluster "sbatch --account=kouyos.virology.uzh --partition=standard --time=2-00:00:00 --cpus-per-task=32 --mem=100G --mail-type=BEGIN,FAIL,END --mail-user=tomas.demeter@uzh.ch --output=slurm_out/slurm-%j.out" --jobs 16
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
METAPHLAN       = RESULT_DIR + "MetaPhlAn4/merged_abundance_table.txt"
METAPHLAN_BBMAP = RESULT_DIR + "MetaPhlAn4_bbmap/merged_abundance_table.txt"
KRAKEN2         = RESULT_DIR + "Kraken2/merged_kraken2_report.csv"

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

############
# Pipeline #
############
rule all:
    input:
        MULTIQC,
        METAPHLAN,
        METAPHLAN_BBMAP,
        KRAKEN2
    message:
        "Metagenomic pipeline run complete!"