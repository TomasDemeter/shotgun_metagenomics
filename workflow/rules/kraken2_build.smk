
rule kraken2_build_standard_db:
    output:
        standard_db     = directory(config["kraken2"]["standard_db"]),
        taxo_k2d        = config["kraken2"]["standard_db"] + "taxo.k2d"
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
        downloaded_genomes = directory(config["kraken2"]["downloaded_genomes"])
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
        names_dmp               = "names.dmp",
        nodes_dmp               = "nodes.dmp",
        nucl_accession2taxid    = "nucl.accession2taxid",
        gtdb_genomes_reps_dir   = directory("gtdb_genomes_reps")
    threads:
        config["kraken2"]["threads"]
    resources: 
        mem_mb = config["kraken2"]["mem_mb"]
    conda:
        "kraken2_env"
    message:
        "Downloading genomes for custom Kraken2 databasefrom GTDB"
    shell:
        "mkdir -p gtdb_genomes_reps; "
        "python3 scripts/download_GTDB_latest.py"


rule rename_fasta_headers:
    input:
        downloaded_genomes_NCBI = rules.download_NCBI_genomes.output.downloaded_genomes,
        downloaded_genomes_GTDB = rules.download_GTDB_genomes.output.gtdb_genomes_reps_dir
    output:
        rename_fasta_headers = directory(config["kraken2"]["rename_fasta_headers"])
    threads:
        config["kraken2"]["threads"]
    resources:
        mem_mb = config["kraken2"]["mem_mb"]
    conda:
        "kraken2_build"
    message:
        "Renaming fasta headers"
    shell:
        "mv {input.downloaded_genomes_GTDB}/* {input.downloaded_genomes_NCBI}; "
        "mkdir -p {output.rename_fasta_headers}; "
        "python3 scripts/rename_fasta_headers.py --processors {threads}; "
        "rm -r {input.downloaded_genomes_GTDB}"


# remove creation of kraken2 parent folder as output. !!!!!

rule kraken2_build_custom_db:
    input:
        downloaded_genomes      = rules.download_NCBI_genomes.output.downloaded_genomes,
        names_dmp               = rules.download_GTDB_genomes.output.names_dmp,
        nodes_dmp               = rules.download_GTDB_genomes.output.nodes_dmp,
        nucl_accession2taxid    = rules.download_GTDB_genomes.output.nucl_accession2taxid,
        rename_fasta_headers    = rules.rename_fasta_headers.output.rename_fasta_headers
    output:
        custom_kraken2_db = directory(config["kraken2"]["custom_kraken2_db"]),
        taxonomy_dir      = directory(config["kraken2"]["custom_kraken2_db"] + "taxonomy"), # this worked before. make dir and move names, nodes and nucl_accession2taxid to taxonomy folder
        #test_build        = "test_build.txt"
    threads:
        config["kraken2"]["threads"]
    resources: 
        mem_mb = 600000,
        time = "4-00:00:00"
    conda:
        "kraken2_env"
    message:
        "Building Kraken2 custom database"
    shell:
        "mkdir -p {output.taxonomy_dir}; " 
        "mv {input.names_dmp} {output.taxonomy_dir}; "
        "mv {input.nodes_dmp} {output.taxonomy_dir}; "
        "mv {input.nucl_accession2taxid} {output.taxonomy_dir}; "
        "python3 scripts/unzip_add_library.py "
        "--genome_folder {input.rename_fasta_headers}/ "
        "--processors {threads} "
        "--database {output.custom_kraken2_db}/; "
        "kraken2-build "
        "--build "
        "--db {output.custom_kraken2_db} "
        "--threads {threads}"
        #"touch {output.test_build}"
