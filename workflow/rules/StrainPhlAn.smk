##########################################################################
# Produce the consensus-marker files which are the input for StrainPhlAn #
##########################################################################
rule consensus_markers:
    input:
        metaphlan_inputs = expand(RESULT_DIR + "MetaPhlAn4/sams/{sample}.sam.bz2", sample=config["StrainPhlAn"]["strainphlan_samples"])
    output:
        consensus_markers   = directory(RESULT_DIR + "StrainPhlAn/consensus_markers/"),
        markers_outputs     = expand(RESULT_DIR + "StrainPhlAn/consensus_markers/{sample}.pkl", sample=config["StrainPhlAn"]["strainphlan_samples"])
    params:
        bowtie_db = config["StrainPhlAn"]["bowtie_db"]
    conda:
        "metaphlan_env"
    threads:
        config["StrainPhlAn"]["threads"]
    message:
        "Producing the consensus-marker files which are the input for StrainPhlAn"
    shell:
        """
        mkdir -p {output.consensus_markers}
        {%- for input, output in zip(input.metaphlan_inputs, output.markers_outputs) %}
        "sample2markers.py -i {input} -o {output} -n {threads} -d {params.bowtie_db}"
        {%- endfor %}
        """

#######################################
# extract the markers for StrainPhlAn #
#######################################
rule extract_markers:
    input:
        bowtie_db = config["StrainPhlAn"]["bowtie_db"]
    output:
        db_markers = directory(RESULT_DIR + "StrainPhlAn/db_markers/")
    params:
        clade = config["StrainPhlAn"]["clade"]
    conda:
        "metaphlan_env"
    threads:
        config["StrainPhlAn"]["threads"]
    message:
        "Extracting the markers from the consensus-marker files"
    shell:
        "mkdir -p {output.db_markers}; "
        "extract_markers.py "
        "-c {params.clade} "
        "-d {input.bowtie_db} "
        "-o {output.db_markers}"

#####################################################################
# StrainPhlAn profiling of the composition of microbial communities #
#####################################################################
rule StrainPhlAn_profiling:
    input:
        db_markers          = rules.extract_markers.output.db_markers,
        markers_output      = rules.consensus_markers.output.markers_output1  # remove the 1 to run for all samples
    output:
        alignments  = directory(RESULT_DIR + "StrainPhlAn/alignments/"),
        output      = RESULT_DIR + "StrainPhlAn/alignments/RAxML_bestTree.s__GCA_000146485.StrainPhlAn4.tre"
    params:
        reference_genomes   = WORKING_DIR + "genomes/strainphlan_genomes/*.bz2",
        consensus_markers   = RESULT_DIR + "StrainPhlAn/consensus_markers/*.pkl",
        clade               = config["StrainPhlAn"]["clade"]
    conda:
        "metaphlan_env"
    threads:
        config["StrainPhlAn"]["threads"]
    message:
        "Producing the consensus-marker files which are the input for StrainPhlAn"
    shell:
        "mkdir -p {output.alignments}; "
        "strainphlan "
        "-s {params.consensus_markers} "
        "-m {input.db_markers} "
        "-r {params.reference_genomes} "
        "-o {output.alignments} "
        "-n {threads} "
        "-c {params.clade} "
        "--mutation_rate"
