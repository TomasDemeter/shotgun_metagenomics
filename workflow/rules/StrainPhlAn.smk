# phylophlan_get_reference -g s__Corynebacterium_accolens -o ../inputs/genomes/PhyloPhlAn_genomes/

##########################################################################
# Produce the consensus-marker files which are the input for StrainPhlAn #
##########################################################################
rule consensus_markers:
    input:
        metaphlan_input1 = RESULT_DIR + "MetaPhlAn4/sams/0010009_unknown_Nasal_Nostrilright.sam.bz2",
        metaphlan_input2 = RESULT_DIR + "MetaPhlAn4/sams/0010020_unknown_Nasal_Nostrilleft.sam.bz2"
    output:
        consensus_markers   = directory(RESULT_DIR + "StrainPhlAn/consensus_markers/"),
        markers_output1     = RESULT_DIR + "StrainPhlAn/consensus_markers/0010009_unknown_Nasal_Nostrilright.pkl",
        markers_output2     = RESULT_DIR + "StrainPhlAn/consensus_markers/0010020_unknown_Nasal_Nostrilleft.pkl"
    params:
        bowtie_db = config["StrainPhlAn"]["bowtie_db"]
    conda:
        "metaphlan_env"
    threads:
        config["StrainPhlAn"]["threads"]
    message:
        "Producing the consensus-marker files which are the input for StrainPhlAn"
    shell:
        "mkdir -p {output.consensus_markers}; "
        "sample2markers.py "
        "-i {input.metaphlan_input1} "
        "-o {output.consensus_markers} "
        "-n {threads} "
        "-d {params.bowtie_db}; "
        "sample2markers.py "
        "-i {input.metaphlan_input2} "
        "-o {output.consensus_markers} "
        "-n {threads} "
        "-d {params.bowtie_db}"

#######################################
# extract the markers for StrainPhlAn #
#######################################
rule extract_markers:
    input:
        bowtie_db = config["StrainPhlAn"]["bowtie_db"]
    output:
        db_markers = RESULT_DIR + "StrainPhlAn/db_markers/"
    params:
        clade = "s__GCA_000146485"
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
        consensus_markers   = rules.consensus_markers.output.consensus_markers,
        markers_output1     = rules.consensus_markers.output.markers_output1,
        markers_output2     = rules.consensus_markers.output.markers_output2
    output:
        alignments  = directory(RESULT_DIR + "StrainPhlAn/alignments/"),
        output      = RESULT_DIR + "StrainPhlAn/alignments/RAxML_bestTree.s__GCA_000146485.StrainPhlAn4.tre"
    params:
        reference_genomes   = WORKING_DIR + "genomes/PhyloPhlAn_genomes/GCA_000146485.fna.gz",
        clade               = "s__GCA_000146485"
    conda:
        "metaphlan_env"
    threads:
        config["StrainPhlAn"]["threads"]
    message:
        "Producing the consensus-marker files which are the input for StrainPhlAn"
    shell:
        "mkdir -p {output.alignments}; "
        "strainphlan "
        "-s {input.consensus_markers} "
        "-m {input.db_markers} "
        "-r {params.reference_genomes} "
        "-o {output.alignments} "
        "-n {threads} "
        "-c {params.clade} "
        "--mutation_rate"
