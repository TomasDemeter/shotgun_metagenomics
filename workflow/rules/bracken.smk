###########################################
# building bracken for standard database #
###########################################
rule bracken_build_std_db:
    input:
        kraken_db = rules.kraken2_build_standard_db.output.standard_db
    output:
        sentinel = WORKING_DIR + "genomes/bracken_std_build_done"
    params:
        kmer_length = config["bracken"]["kmer_length"],
        read_length = config["bracken"]["read_length"]
    message:
        "Dividing each genome in Kraken2 standard database and classifying them with Bracken"
    threads:
        config["bracken"]["threads"]
    resources: 
        mem_mb = config["bracken"]["mem_mb"],
    conda: 
        "kraken2_env"
    shell:
        "bracken-build "
        "-d {input.kraken_db} "
        "-t {threads} "
        "-k {params.kmer_length} "
        "-l {params.read_length}; "
        "touch {output.sentinel}"

########################################
# building bracken for custom database #
########################################
rule bracken_build_cst_db:
    input:
        kraken_db = rules.kraken2_build_custom_db.output.custom_kraken2_db
    output:
        sentinel = WORKING_DIR + "genomes/bracken_cst_build_done"
    params:
        kmer_length = config["bracken"]["kmer_length"],
        read_length = config["bracken"]["read_length"]
    message:
        "Dividing each genome in Kraken2 custom database and classifying them with Bracken"
    threads:
        config["bracken"]["threads"]
    resources: 
        mem_mb = config["bracken"]["mem_mb"],
        time = "7-00:00:00"
    conda: 
        "kraken2_env"
    shell:
        "bracken-build "
        "-d {input.kraken_db} "
        "-t {threads} "
        "-k {params.kmer_length} "
        "-l {params.read_length}; "
        "touch {output.sentinel}"


###################
# running bracken #
###################
rule bracken:
    input:
        kraken_output = rules.kraken2.output.report,
        kraken_db     = rules.kraken2_build_standard_db.output.standard_db,
        bracken_db    = rules.bracken_build_std_db.output.sentinel
    output:
        bracken_output   = RESULT_DIR + "Bracken/{sample}.bracken",
        bracken_report   = RESULT_DIR + "Bracken/{sample}_bracken_report.txt"
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
        "-d {input.kraken_db}"
        "-i {input.kraken_output} "
        "-o {output.bracken_output} "
        "-w {output.bracken_report} "
        "-r {params.read_length} "
        "-t {params.treshold} "
        "-l {params.classification_level}"


###################
# create test file #
###################
rule create_test_file:
    input:
        bracken_output = expand(rules.bracken.output.bracken_output, sample=SAMPLES)
    output:
        bracken_test = RESULT_DIR + "Bracken/test.txt"
    shell:
        "touch {output.bracken_test}"