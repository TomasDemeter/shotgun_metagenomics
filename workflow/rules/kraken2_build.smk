
rule kraken2_build_standard_db:
    output:
        standard_db     = touch(directory(config["kraken2"]["standard_db"])),
        taxo_k2d        = touch(config["kraken2"]["standard_db"] + "taxo.k2d")
    params:
        standard_db_url = config["kraken2"]["standard_db_url"]
    message:
        "Downloading and building Kraken2 standard database"
    shell:
        "mkdir -p {output.standard_db}; "
        "wget -P {output.standard_db} {params.standard_db_url}; "
        "tar -xzf {output.standard_db}/*.tar.gz -C {output.standard_db}"
        

rule download_NCBI_genomes:
    output:
        downloaded_genomes = touch(directory(config["kraken2"]["downloaded_genomes"]))
    params:
        domain = config["kraken2"]["domains"]
    threads:
        config["kraken2"]["threads"]
    resources: 
        mem_mb = config["kraken2"]["mem_mb"]
    conda:
        "kraken2_env"
    message:
        "Downloading genomes for custom Kraken2 database from NCBI"
    shell:
        "python3 scripts/get_ncbi_other_domains.py "
        "--domain {params.domain} "
        "--folder {output.downloaded_genomes} "
        "--processors {threads}"

rule download_GTDB_genomes:
    output:
        names_dmp               = config["kraken2"]["custom_kraken2_db"] + "names.dmp",
        nodes_dmp               = config["kraken2"]["custom_kraken2_db"] + "nodes.dmp",
        nucl_accession2taxid    = config["kraken2"]["custom_kraken2_db"] + "nucl.accession2taxid",
        custom_kraken2_db       = directory(config["kraken2"]["custom_kraken2_db"])
    params:
        downloaded_genomes      = directory(config["kraken2"]["downloaded_genomes"]),
    threads:
        config["kraken2"]["threads"]
    resources: 
        mem_mb = config["kraken2"]["mem_mb"]
    conda:
        "kraken2_env"
    message:
        "Downloading genomes for custom Kraken2 databasefrom GTDB"
    shell:
        "python3 scripts/download_GTDB_latest.py; "
        "mkdir -p {output.custom_kraken2_db}/taxonomy; "
        "mv names.dmp {output.custom_kraken2_db}/taxonomy; "
        "mv nodes.dmp {output.custom_kraken2_db}/taxonomy; "
        "mv nucl.accession2taxid {output.custom_kraken2_db}/taxonomy; "
        "mv gtdb_genomes_reps/* {params.downloaded_genomes}; "

rule kraken2_build_custom_db:
    input:
        downloaded_genomes      = rules.download_NCBI_genomes.output.downloaded_genomes,
        names_dmp               = rules.download_GTDB_genomes.output.names_dmp,
        nodes_dmp               = rules.download_GTDB_genomes.output.nodes_dmp,
        nucl_accession2taxid    = rules.download_GTDB_genomes.output.nucl_accession2taxid
    output:
        custom_kraken2_db = touch(directory(config["kraken2"]["custom_kraken2_db"]))
    threads:
        config["kraken2"]["threads"]
    resources: 
        mem_mb = config["kraken2"]["mem_mb"]
    conda:
        "kraken2_env"
    message:
        "Building Kraken2 custom database"
    shell:        
        "python3 scripts/unzip_add_library.py "
        "--genome_folder {input.downloaded_genomes}/ "
        "--processors {threads} "
        "--database {output.custom_kraken2_db}; "
        "kraken2-build "
        "--build "
        "--db {output.custom_kraken2_db} "
        "--threads {threads}"
