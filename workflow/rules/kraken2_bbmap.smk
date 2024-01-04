#####################################################################
# Kraken 2 profiling of the composition of microbial communities #
#####################################################################
rule kraken2_bbmap:
    input:
        unmapped1 = rules.bbmap_default.output.unmapped1,
        unmapped2 = rules.bbmap_default.output.unmapped2
    output:
        report          = RESULT_DIR + "Kraken2_bbmap/{sample}_kraken2_report.txt",
        classified1     = RESULT_DIR + "Kraken2_bbmap/{sample}_classified_1.fq",
        classified2     = RESULT_DIR + "Kraken2_bbmap/{sample}_classified_2.fq",
        unclassified1   = RESULT_DIR + "Kraken2_bbmap/{sample}_unclassified_1.fq",
        unclassified2   = RESULT_DIR + "Kraken2_bbmap/{sample}_unclassified_2.fq"
    params:
        kraken2_db      = config["kraken2"]["kraken2_db"],
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
        "--db {params.kraken2_db} "
        "--{params.paired} "
        "--threads {threads} "
        "--{params.gzip_compressed} " 
        "--classified-out {params.classified} "
        "--unclassified-out {params.unclassified} "
        "{input.unmapped1} "
        "{input.unmapped2} "
        "--confidence {params.confidence} "
        "--report {output.report}"

####################################################
# Generating metaphlan style reports from Kraken2 #
####################################################
rule kraken2mpa_bbmap:
    input:
        report = rules.kraken2_bbmap.output.report
    output:
        mpa_report = RESULT_DIR + "Kraken2_bbmap/metaphlan_style_reports/{sample}_kraken2_mpa_report.txt"
    params:
        report_style = config["kraken2"]["report_style"]
    conda:
        "kraken2_env"
    message:
        "Converting Kraken 2 report to MetaPhlAn style report"
    shell:
        "python3 scripts/kraken2mpa_modified.py "
        "--{params.report_style} "
        "-r{input.report} "
        "-o{output.mpa_report}"

#################################################
# Merging Kraken2 reports from multiple samples #
#################################################
rule merge_kraken2_bbmap:
    input:
        reports = expand(rules.kraken2mpa_bbmap.output.mpa_report, sample = SAMPLES)
    output:
        merged_report = RESULT_DIR + "merged_csv_files/Kraken2_Bbmap_merged.csv"
    params:
        file_dir    = RESULT_DIR + "Kraken2_bbmap/metaphlan_style_reports/",
        output_file = "Kraken2_Bbmap_merged.csv",
        output_dir  = RESULT_DIR + "merged_csv_files/"
    message:
        "Merging MetaPhlAn 4 composition profiles"
    conda: 
        "metaphlan_env"
    shell:
        "python3 scripts/kraken2_merging.py "
        "{params.file_dir} "
        "{params.output_dir} "
        "{params.output_file}"