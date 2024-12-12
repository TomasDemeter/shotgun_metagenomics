############################
# Creating phyloseq object #
############################
rule create_phyloseq:
    input:
        kraken2_bowtie          = rules.kraken2processing.output.merged_kraken2_report,
        bracken_bowtie          = rules.bracken2processing.output.merged_bracken_report,
        metaphlan4_bowtie       = rules.metaphlan4processing.output.merged_metaphlan4_report,
    output:
        bowtie_metaphlan_rds    = RESULT_DIR + "Phyloseq/Metaphlan4_Bowtie_report.rds",
        bowtie_kraken_rds       = RESULT_DIR + "Phyloseq/Kraken2_Bowtie_report.rds",
        bowtie_bracken_rds      = RESULT_DIR + "Phyloseq/Bracken_Bowtie_report.rds"
    params:
        reports_dir             = RESULT_DIR + "Kraken_Bracken_Metaphlan_output",
        output_dir              = RESULT_DIR + "Phyloseq/",
        metadata                = config["refs"]["samples"]
    message:
        "Creating phyloseq objects"
    conda: 
        "phyloseq_env"
    shell:
        "mkdir -p {params.output_dir}; "
        "Rscript ./scripts/create_phyloseq.R "
        "-r {params.reports_dir} "
        "-m {params.metadata} "
        "-o {params.output_dir} "
