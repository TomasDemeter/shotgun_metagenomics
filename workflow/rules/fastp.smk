#########################
# seq read trimming #
#########################
rule fastp:
    input:
        read_1              = WORKING_DIR + "raw_reads/{sample}_1.fq.gz",
        read_2              = WORKING_DIR + "raw_reads/{sample}_2.fq.gz"
    output:   
        trimmed_1           = WORKING_DIR + "fastp/{sample}_1.fastq.gz",
        trimmed_2           = WORKING_DIR + "fastp/{sample}_2.fastq.gz",
        html                = WORKING_DIR + "fastp/logs/{sample}_fastp.html",
        json                = WORKING_DIR + "fastp/logs/{sample}_fastp.json"        
    message:
        "fastp trimming {wildcards.sample} reads"
    conda: 
        "fastp_bowtie2"
    params:
        cut_window_size     = config["fastp"]["cut_window_size"],
        cut_mean_quality    = config["fastp"]["cut_mean_quality"], 
        length_required     = config["fastp"]["length_required"],
        phread_quality      = config["fastp"]["phread_quality"],
        adapters            = config["refs"]["adapters"]
    shell:
        "mkdir -p {WORKING_DIR}fastp/logs; "
        "fastp "
        "-i {input.read_1} "
        "-I {input.read_2} "
        "-o {output.trimmed_1} "
        "-O {output.trimmed_2} "
        "--thread {resources.cpus_per_task} "
        "--qualified_quality_phred {params.phread_quality} "
        "--cut_front "
        "--cut_tail "
        "--cut_window_size {params.cut_window_size} "
        "--cut_mean_quality {params.cut_mean_quality} "
        "--length_required {params.length_required} "
        "--html {output.html} "
        "--json {output.json} "
        "--adapter_fasta {params.adapters}"
