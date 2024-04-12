############################################
# build indexes and database for MetaPhlAn #
############################################
rule MetaPhlAn4_build:
    output:
        metaphlan_bowtie2db = directory(config["MetaPhlAn4_profiling"]["bowtie2db"])
    message:
        "Building MetaPhlAn 4 database"
    threads:
        config["MetaPhlAn4_profiling"]["threads"]
    resources:
        mem_mb = config["MetaPhlAn4_profiling"]["mem_mb"]
    conda: 
        "metaphlan_env"
    shell:
        "metaphlan --install --bowtie2db {output.metaphlan_bowtie2db}"