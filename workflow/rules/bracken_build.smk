###########################################
# building bracken for standard database #
###########################################
rule bracken_build_std_db:
    input:
        kraken_db   = rules.kraken2_build_standard_db.output.standard_db
    output:
        sentinel    = WORKING_DIR + "genomes/bracken_std_build_done"
    params:
        kmer_length = config["bracken"]["kmer_length"],
        read_length = config["bracken"]["read_length"]
    message:
        "Dividing each genome in Kraken2 standard database and classifying them with Bracken"
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
        kraken_db   = rules.kraken2_build_custom_db.output.custom_kraken2_db
    output:
        sentinel    = WORKING_DIR + "genomes/bracken_cst_build_done"
    params:
        kmer_length = config["bracken"]["kmer_length"],
        read_length = config["bracken"]["read_length"]
    message:
        "Dividing each genome in Kraken2 custom database and classifying them with Bracken"
    conda: 
        "kraken2_env"
    shell:
        "bracken-build "
        "-d {input.kraken_db} "
        "-t {threads} "
        "-k {params.kmer_length} "
        "-l {params.read_length}; "
        "touch {output.sentinel}"
