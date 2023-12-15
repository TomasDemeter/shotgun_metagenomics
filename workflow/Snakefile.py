########################################################
# Snakemake pipeline for shotgun metagenomics analysis #
########################################################
'''
snakemake -s Snakefile.py --use-conda --rerun-incomplete --keep-going --cluster "sbatch --account=kouyos.virology.uzh --partition=standard --time=5-00:00:00 --cpus-per-task=32 --mem=100G --mail-type=BEGIN,FAIL,END --mail-user=tomas.demeter@uzh.ch" --jobs 8

snakemake -s Snakefile.py --use-conda --rerun-incomplete --keep-going --cluster "sbatch --account=kouyos.virology.uzh --partition=standard --time=24:00:00 --cpus-per-task=32 --mem=100G --mail-type=BEGIN,FAIL,END --mail-user=tomas.demeter@uzh.ch" --jobs 8

snakemake -s Snakefile.py --use-conda --rerun-incomplete --keep-going --cluster "sbatch --account=kouyos.virology.uzh --partition=standard --time=09:00:00 --cpus-per-task=32 --mem=100G --mail-type=FAIL,END --mail-user=tomas.demeter@uzh.ch --output=slurm_out/slurm-%j.out" --jobs 16
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
METAPHLAN       = RESULT_DIR + "MetaPhlAn4/metaphlan_output_merged.csv"
METAPHLAN_BBMAP = RESULT_DIR + "MetaPhlAn4_bbmap/metaphlan_output_merged.csv"
KRAKEN2         = RESULT_DIR + "Kraken2/metaphlan_style_reports/kraken2_output_merged.csv"
KRAKEN2_BBMAP   = RESULT_DIR + "Kraken2_bbmap/metaphlan_style_reports/kraken2_output_merged.csv"

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

############
# Pipeline #
############
rule all:
    input:
        MULTIQC,
        METAPHLAN,
        METAPHLAN_BBMAP,
        KRAKEN2,
        KRAKEN2_BBMAP
    message:
        "Metagenomic pipeline run complete!"