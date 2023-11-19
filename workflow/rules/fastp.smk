#########################
# RNA-seq read trimming #
#########################
rule fastp:
    input:
        read_1 = WORKING_DIR + "raw_reads/{ERR}_1.fastq.gz",
        read_2 = WORKING_DIR + "raw_reads/{ERR}_2.fastq.gz"
    output:
        trimmed_1   = WORKING_DIR + "fastp/{ERR}_1.fastq.gz",
        trimmed_2   = WORKING_DIR + "fastp/{ERR}_2.fastq.gz",
        html        = WORKING_DIR + "fastp/logs/{ERR}_fastp.html",
        json        = WORKING_DIR + "fastp/logs/{ERR}_fastp.json"
    message:
        "trimming {wildcards.ERR} reads"
    threads:
        config["fastp"]["threads"]
    conda: 
        "fastp_bowtie2"
    log:
        log_file = WORKING_DIR + "fastp/logs/{ERR}.log.txt"
    params:
        phread_quality      = config["fastp"]["phread_quality"],
        base_limit          = config["fastp"]["base_limit"],
        percent_limit       = config["fastp"]["percent_limit"]
    shell:
        "mkdir -p {WORKING_DIR}fastp/logs; "
        "fastp "
        "-i {input.read_1} "
        "-I {input.read_2} "
        "-o {output.trimmed_1} "
        "-O {output.trimmed_2} "
        "--thread {threads} "
        "--qualified_quality_phred {params.phread_quality} "
        "--unqualified_percent_limit {params.percent_limit} "
        "--n_base_limit {params.base_limit} "
        "--html {output.html} "
        "--json {output.json} "
        "2>{log.log_file}"