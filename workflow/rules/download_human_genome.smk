#########################
# download human genome #
#########################
rule download_human_genome:
    output:
        human_genome_ensembl = config["refs"]["human_genome"]
    params:
        ensembl_link = config["refs"]["human_genome_ensembl_link"],
        human_genome_dir = config["refs"]["human_genome_dir"]
    message:
        "Downloading human genome from Ensembl"
    shell:
        "mkdir -p {params.human_genome_dir}; "
        "wget -P {params.human_genome_dir} {params.ensembl_link}"