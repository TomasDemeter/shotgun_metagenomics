#####################################################################
# Kraken 2 profiling of the composition of microbial communities #
#####################################################################
rule kraken2:
    input:
        unmapped1 = rules.bowtie2_mapping.output.unmapped1,
        unmapped2 = rules.bowtie2_mapping.output.unmapped2
    output:
        report = RESULT_DIR + "Kraken2/{ERR}_kraken2_report.txt",
        classified1 = RESULT_DIR + "Kraken2/{ERR}_classified_1.fq",
        classified2 = RESULT_DIR + "Kraken2/{ERR}_classified_2.fq",
        unclassified1 = RESULT_DIR + "Kraken2/{ERR}_unclassified_1.fq",
        unclassified2 = RESULT_DIR + "Kraken2/{ERR}_unclassified_2.fq"
    params:
        kraken2_db = config["kraken2"]["kraken2_db"],
        paired = config["kraken2"]["paired"],
        gzip_compressed = config["kraken2"]["gzip_compressed"],
        file_format = config["kraken2"]["file_format"],
        classified = RESULT_DIR + "Kraken2/{ERR}_classified#.fq",
        unclassified = RESULT_DIR + "Kraken2/{ERR}_unclassified#.fq"
    threads:
        config["kraken2"]["threads"]
    resources: 
        mem_mb = config["kraken2"]["mem_mb"]
    conda:
        "kraken2_env"
    message:
        "Kraken 2 profiling of the composition of microbial communities in {wildcards.ERR}"
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
        "--{params.file_format} "
        "--report {output.report}"

rule merge_kraken2:
    input:
        reports = expand(rules.kraken2.output.report, ERR = SAMPLES)
    params:
        kraken2_dir = RESULT_DIR + "Kraken2/"
    output:
        merged_report = RESULT_DIR + "Kraken2/merged_kraken2_report.csv"
    conda:
        "kraken2_env"
    message:
        "Merging Kraken 2 reports"
    shell:
        "python3 scripts/kraken2_merging.py {params.kraken2_dir}"