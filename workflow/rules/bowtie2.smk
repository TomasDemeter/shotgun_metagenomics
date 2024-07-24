#############################
# Genome reference indexing #
#############################
rule bowtie2_index:
    input:
        human_genome = rules.download_human_genome.output.human_genome_ensembl
    output:
        genome_index = directory(config["refs"]["bowtie_index"])
    message:
        "generating Bowtie2 genome index"
    conda: 
        "fastp_bowtie2"
    shell:
        "mkdir -p {output.genome_index}; "
        "bowtie2-build "
        "{input.human_genome} "
        "{output.genome_index}/GRCh38_index "
        "--threads {resources.cpus_per_task}"

#################################
# Mapping reads to human genome #
#################################
rule bowtie2_mapping:
    input:
        genome_index        = rules.bowtie2_index.output.genome_index,
        read_1              = rules.fastp.output.trimmed_1,
        read_2              = rules.fastp.output.trimmed_2
    output:
        aligned_sam         = temp(WORKING_DIR + "Bowtie2/{sample}_aligned.sam"),
        unmapped1           = WORKING_DIR + "Bowtie2/{sample}_unmapped.1.gz",
        unmapped2           = WORKING_DIR + "Bowtie2/{sample}_unmapped.2.gz",
        logs                = WORKING_DIR + "Bowtie2/logs/{sample}_bowtie2.txt"
    params:
        unmapped_prefix     = WORKING_DIR + "Bowtie2/{sample}_unmapped",
    message:
        "Mapping {wildcards.sample} reads to human genome using Bowtie2"
    conda: 
        "fastp_bowtie2"
    shell:
        "mkdir -p {WORKING_DIR}Bowtie2/logs/; "
        "bowtie2 "
        "-x {input.genome_index}/GRCh38_index "
        "-1 {input.read_1} "
        "-2 {input.read_2} "
        "-S {output.aligned_sam} "
        "--un-conc-gz {params.unmapped_prefix}.gz "
        "--very-sensitive "
        "--dovetail "
        "--threads {resources.cpus_per_task} "
        "2> {output.logs}"
