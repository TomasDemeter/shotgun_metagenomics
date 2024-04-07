###################
# running bracken #
###################
rule bracken_bbmap:
    input:
        kraken_output = rules.kraken2_bbmap.output.report,
        #kraken_db     = rules.kraken2_build_standard_db.output.standard_db,
        kraken_db     = rules.kraken2_build_custom_db.output.custom_kraken2_db,
        bracken_db    = rules.bracken_build_std_db.output.sentinel
    output:
        bracken_output   = config["bracken"]["output_dir_bbmap"] + "{sample}.bracken",
        bracken_report   = config["bracken"]["output_dir_bbmap"] + "{sample}_bracken_report.txt"
    params:
        classification_level    = config["bracken"]["classification_level"],
        treshold                = config["bracken"]["treshold"],
        read_length             = config["bracken"]["read_length"]
    message:
        "Running Bracken on Kraken2 output"
    threads:
        config["bracken"]["threads"]
    resources: 
        mem_mb = config["bracken"]["mem_mb"],
    shell:
        "bracken "
        "-d {input.kraken_db} "
        "-i {input.kraken_output} "
        "-o {output.bracken_output} "
        "-w {output.bracken_report} "
        "-r {params.read_length} "
        "-t {params.treshold} "
        "-l {params.classification_level}"

#############################################
# Generating csv style reports from Bracken #
#############################################
rule bracken2processing_bbmap:
    input:
        report_inputs   = expand(rules.bracken_bbmap.output.bracken_report, sample = SAMPLES),
    output:
        merged_bracken_report = config["kraken2"]["csv_output_merged"] + "Bracken_BBmap_report.csv"
    params:
        reports = config["bracken"]["output_dir_bbmap"]
    conda:
        "kraken2_env"
    message:
        "Converting bracken txt reports to csv merged report"
    shell:
        "python3 scripts/kraken2_processing.py "
        "{params.reports} "
        "{output.merged_bracken_report}"