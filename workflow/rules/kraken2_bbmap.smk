#####################################################################
# Kraken 2 profiling of the composition of microbial communities #
#####################################################################
rule kraken2_bbmap:
    input:
        unmapped1   = rules.bbmap_default.output.unmapped1,
        unmapped2   = rules.bbmap_default.output.unmapped2,
        kraken2_db  = rules.kraken2_build_custom_db.output.custom_kraken2_db
        #kraken2_db  = rules.kraken2_build_standard_db.output.standard_db
    output:
        report          = RESULT_DIR + "Kraken2_bbmap/{sample}_kraken2_report.txt",
        classified1     = RESULT_DIR + "Kraken2_bbmap/{sample}_classified_1.fq",
        classified2     = RESULT_DIR + "Kraken2_bbmap/{sample}_classified_2.fq",
        unclassified1   = RESULT_DIR + "Kraken2_bbmap/{sample}_unclassified_1.fq",
        unclassified2   = RESULT_DIR + "Kraken2_bbmap/{sample}_unclassified_2.fq"
    params:
        paired          = config["kraken2"]["paired"],
        gzip_compressed = config["kraken2"]["gzip_compressed"],
        confidence      = config["kraken2"]["confidence"],
        classified      = RESULT_DIR + "Kraken2_bbmap/{sample}_classified#.fq",
        unclassified    = RESULT_DIR + "Kraken2_bbmap/{sample}_unclassified#.fq"
    threads:
        config["kraken2"]["threads"]
    resources: 
        mem_mb = config["kraken2"]["mem_mb"]
    conda:
        "kraken2_env"
    message:
        "Kraken 2 profiling of the composition of microbial communities in {wildcards.sample}"
    shell:
        "kraken2 "
        "--db {input.kraken2_db} "
        "--{params.paired} "
        "--threads {threads} "
        "--{params.gzip_compressed} "
        "--classified-out {params.classified} "
        "--unclassified-out {params.unclassified} "
        "{input.unmapped1} "
        "{input.unmapped2} "
        "--confidence {params.confidence} "
        "--report {output.report}"

#############################################
# Generating csv style reports from Kraken2 #
#############################################
rule kraken2processing_bbmap:
    input:
        report_inputs   = expand(rules.kraken2_bbmap.output.report, sample = SAMPLES),
    output:
        merged_kraken2_report = config["kraken2"]["csv_output_merged"] + "Kraken2_BBmap_report.csv"
    params:
        reports = RESULT_DIR + "Kraken2/"
    conda:
        "kraken2_env"
    message:
        "Converting Kraken 2 txt reports to csv merged report"
    shell:
        "python3 scripts/kraken2_processing.py "
        "{params.reports} "
        "{output.merged_kraken2_report}"