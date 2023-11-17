#############################
# Genome reference indexing #
#############################
rule bowtie_index:
    input:
        human_genome = config["refs"]["human_genome"]
    output:
        genome_index = directory(config["refs"]["index"])
    message:
        "generating Bowtie genome index"
    threads:
        config["bowtie"]["threads"]
    conda: 
        "fastp_bowtie"
    shell:
        "mkdir -p {output.genome_index}; "
        "bowtie-build "
        "{input.human_genome} "
        "{output.genome_index}/GRCh38_index "
        "--threads {threads}"

#################################
# Mapping reads to human genome #
#################################
rule bowtie_mapping:
    input:
        human_genome = rules.bowtie_index.output.genome_index,
        read_1 = rules.fastp.output.trimmed_1,
        read_2 = rules.fastp.output.trimmed_2
    output:
        mapped_to_human1    = temp(WORKING_DIR + "Bowtie/{ERR}_human1.fq.gz"),
        mapped_to_human2    = temp(WORKING_DIR + "Bowtie/{ERR}_human2.fq.gz"),
        unmapped1           = WORKING_DIR + "Bowtie/{ERR}_bowtie_unmapped1.fq.gz",
        unmapped2           = WORKING_DIR + "Bowtie/{ERR}_bowtie_unmapped2.fq.gz",
        log                 = WORKING_DIR + "Bowtie/logs/{ERR}_fastp_Log.final.out"
    message:
        "Mapping {wildcards.ERR} reads to human genome using Bowtie"
    threads:
        config["bowtie"]["threads"]
    conda: 
        "fastp_bowtie"
    shell:
        "mkdir -p {WORKING_DIR}Bowtie/logs; "
        "bowtie2 "
        "-x {input.human_genome} "
        "-1 {input.read_1} "
        "-2 {input.read_2} "
        "--un-conc {WORKING_DIR}Bowtie/{wildcards.ERR}_bowtie_unmapped "
        "--threads {threads} "
        "2> {output.log}"

