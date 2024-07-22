##########################################
# subsampling filtered reads using seqtk #
##########################################
rule plotting_kraken_metaphlan:
    input:
        kraken2_bowtie      = rules.kraken2processing.output.merged_kraken2_report,
        kraken2_bbmap       = rules.kraken2processing_bbmap.output.merged_kraken2_report,
        bracken_bowtie      = rules.bracken2processing.output.merged_bracken_report,
        bracken_bbmap       = rules.bracken2processing_bbmap.output.merged_bracken_report,
        metaphlan4_bowtie   = rules.metaphlan4processing.output.merged_metaphlan4_report,
        metaphlan4_bbmap    = rules.metaphlan4processing_bbmap.output.merged_metaphlan4_report
    output:
        fig                 = config["plotting_kraken_metaphlan"]["csv_location"] + "figures/kraken2_bbmap_domains.png"
    params:
        csv_location        = config["plotting_kraken_metaphlan"]["csv_location"],
        output_dir          = config["plotting_kraken_metaphlan"]["csv_location"] + "figures/", 
        min_reads           = config["plotting_kraken_metaphlan"]["min_reads"],
        relative_abundance  = config["plotting_kraken_metaphlan"]["relative_abundance"]
    message:
        "Plotting results"
    conda: 
        "kraken2_env"
    shell:
        "mkdir -p {params.output_dir}; "
        "python scripts/plotting_abundances.py {params.csv_location} {params.output_dir} {params.min_reads} {params.relative_abundance}; "
        "python scripts/plotting_comparisons.py {params.csv_location} {params.output_dir} {params.min_reads} {params.relative_abundance}"
