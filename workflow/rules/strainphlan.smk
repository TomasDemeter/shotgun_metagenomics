##########################################################################
# Produce the consensus-marker files which are the input for StrainPhlAn #
##########################################################################
rule consensus_markers:
    input:
        metaphlan_inputs = expand(RESULT_DIR + "MetaPhlAn4/sams/{sample}.sam.bz2", sample=config["StrainPhlAn"]["strainphlan_samples"])
    output:
        consensus_markers_dir   = directory(RESULT_DIR + "StrainPhlAn/consensus_markers/"),
        markers_outputs         = expand(RESULT_DIR + "StrainPhlAn/consensus_markers/{sample}.pkl", sample=config["StrainPhlAn"]["strainphlan_samples"])
    params:
        database = config["MetaPhlAn4_profiling"]["bowtie2db"] + config["MetaPhlAn4_profiling"]["index"] + ".pkl"
    conda:
        "metaphlan_env"
    threads:
        config["StrainPhlAn"]["threads"]
    resources:
        mem_mb = config["StrainPhlAn"]["mem_mb"]
    message:
        "Producing the consensus-marker files which are the input for StrainPhlAn"
    shell:
        "mkdir -p {output.consensus_markers_dir}; "
        "sample2markers.py "
        "--input {input} "
        "--output_dir {output.consensus_markers_dir} "
        "--database {params.database} "
        "--nprocs {threads}"

#######################################
# extract the markers for StrainPhlAn #
#######################################
rule extract_markers:
    input:
        consensus_markers_dir = rules.consensus_markers.output.consensus_markers_dir
    output:
        clade_markers_dir   = directory(RESULT_DIR + "StrainPhlAn/clade_markers/"),
        clade_markers       = RESULT_DIR + "StrainPhlAn/clade_markers/" + config["StrainPhlAn"]["clade"] + ".fna"
    params:
        clades      = config["StrainPhlAn"]["clade"],
        database    = config["MetaPhlAn4_profiling"]["bowtie2db"] + config["MetaPhlAn4_profiling"]["index"] + ".pkl"
    conda:
        "metaphlan_env"
    threads:
        config["StrainPhlAn"]["threads"]
    resources:
        mem_mb = config["StrainPhlAn"]["mem_mb"]
    message:
        "Extracting the markers from the consensus-marker files"
    shell:
        "mkdir -p {output.clade_markers_dir}; "
        "extract_markers.py "
        "--clades {params.clades} "
        "--database {params.database} "
        "--output_dir {output.clade_markers_dir}"

#####################################################################
# StrainPhlAn profiling of the composition of microbial communities #
#####################################################################
rule StrainPhlAn_profiling:
    input:
        clade_markers_dir   = rules.extract_markers.output.clade_markers_dir,
        markers_output      = rules.consensus_markers.output.markers_outputs,
        clade_markers       = rules.extract_markers.output.clade_markers
    output:
        #output_tree         = RESULT_DIR + "StrainPhlAn/alignments/RAxML_bestTree." + config["StrainPhlAn"]["clade"] + ".StrainPhlAn4.tre",
        alignments_dir      = directory(RESULT_DIR + "StrainPhlAn/alignments/"),
        clades_list         = RESULT_DIR + "StrainPhlAn/alignments/print_clades_only.tsv"
    params:
        reference_genomes   = WORKING_DIR + "genomes/strainphlan_genomes/*.bz2",
        consensus_markers   = RESULT_DIR + "StrainPhlAn/consensus_markers/*.pkl",
        clade               = config["StrainPhlAn"]["clade"],
        database            = config["MetaPhlAn4_profiling"]["bowtie2db"] + config["MetaPhlAn4_profiling"]["index"] + ".pkl"
    conda:
        "metaphlan_env"
    threads:
        config["StrainPhlAn"]["threads"]
    resources:
        mem_mb = config["StrainPhlAn"]["mem_mb"]
    message:
        "Producing the consensus-marker files which are the input for StrainPhlAn"
    shell:
        "mkdir -p {output.alignments_dir}; "
        "strainphlan "
        "--samples {params.consensus_markers} "
        #"--clade_markers {input.clade_markers} "
        "--references {params.reference_genomes} "
        "--output_dir {output.alignments_dir} "
        "--nprocs {threads} "
        "--clade {params.clade} "
        "--database {params.database} "
        "--mutation_rate "
        "--print_clades_only"
