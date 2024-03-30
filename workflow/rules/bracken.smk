#####################
# building bracken  #
#####################
rule bracken_build:
    input:
        kraken_db = rules.kraken2_build_standard_db.output.standard_db
    output:
        bracken_db = RESULT_DIR + "test.txt"
    params:
        kmer_length = config["bracken"]["kmer_length"],
        read_length = config["bracken"]["read_length"]
    message:
        "Dividing each genome in Kraken2 database and classifying them with Bracken"
    threads:
        config["bracken"]["threads"]
    resources: 
        mem_mb = config["bracken"]["mem_mb"],
        #time = config["bracken"]["time"]
    conda: 
        "kraken2_env"
    shell:
        "bracken-build -d {input.kraken_db} -t {threads} -k {params.kmer_length} -l {params.read_length}; "
        "touch {output.bracken_db}"
