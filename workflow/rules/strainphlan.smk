####################
# python functions #
####################
# read output of StrainPhlAn_get_SGB to get the clade names
def get_all_clades(clades_file):
    with open(clades_file, 'r') as f:
        # Skip the header line
        next(f)
        # Read only the first column, strip whitespace
        return [line.split('\t')[0].strip() for line in f if line.strip()]

# read the clades_list file and determine which tree files need to be generated
def get_all_trees(wildcards):
    checkpoint_output = checkpoints.StrainPhlAn_get_SGB.get(**wildcards).output[0]
    clades = get_all_clades(checkpoint_output)
    return expand(RESULT_DIR + "StrainPhlAn/alignments/{clade}/RAxML_bestTree.{clade}.StrainPhlAn4.tre",
                  clade=clades)

def get_all_visualizations(wildcards):
    checkpoint_output = checkpoints.StrainPhlAn_get_SGB.get(**wildcards).output[0]
    clades = get_all_clades(checkpoint_output)
    return expand(RESULT_DIR + "StrainPhlAn/visualizations/{clade}_tree_1.png",
                  clade=clades)

######################################
# Produce the consensus-marker files #
######################################
rule sample2markers:
    input:
        metaphlan_inputs        = expand(RESULT_DIR + "MetaPhlAn4/sams/{sample}.sam.bz2", sample=SAMPLES)
    output:
        consensus_markers_dir   = directory(RESULT_DIR + "StrainPhlAn/consensus_markers/"),
        markers_outputs         = expand(RESULT_DIR + "StrainPhlAn/consensus_markers/{sample}.pkl", sample=SAMPLES)
    params:
        database                = config["MetaPhlAn4_profiling"]["bowtie2db"] + config["MetaPhlAn4_profiling"]["index"] + ".pkl"
    conda:
        "metaphlan_env"
    message:
        "Producing the consensus-marker files from MetaPhlAn output"
    shell:
        "mkdir -p {output.consensus_markers_dir}; "
        "sample2markers.py "
        "--input {input} "
        "--output_dir {output.consensus_markers_dir} "
        "--database {params.database} "
        "--nprocs $(nproc)"

#######################
# StrainPhlAn get SGB #
#######################
checkpoint StrainPhlAn_get_SGB:
    input:
        consensus_markers                   = rules.sample2markers.output.markers_outputs,
    output:
        clades_list                         = RESULT_DIR + "StrainPhlAn/alignments/print_clades_only.tsv"
    params:
        alignments_dir                      = RESULT_DIR + "StrainPhlAn/alignments/",
        database                            = config["MetaPhlAn4_profiling"]["bowtie2db"] + config["MetaPhlAn4_profiling"]["index"] + ".pkl",
        mutation_rates                      = config["StrainPhlAn"]["mutation_rates"],
        marker_in_n_samples                 = config["StrainPhlAn"]["marker_in_n_samples"],
        sample_with_n_markers               = config["StrainPhlAn"]["sample_with_n_markers"],
        sample_with_n_markers_after_filt    = config["StrainPhlAn"]["sample_with_n_markers_after_filt"]
    conda:
        "metaphlan_env"
    message:
        "Producing the Strain Genome Bins files using StrainPhlAn"
    shell:
        "mkdir -p {params.alignments_dir}; "
        "strainphlan "
        "--samples {input.consensus_markers} "
        "--output_dir {params.alignments_dir} "
        "--nprocs {resources.cpus_per_task} "
        "--print_clades_only "
        "--database {params.database} "
        "--marker_in_n_samples {params.marker_in_n_samples} "
        "--sample_with_n_markers {params.sample_with_n_markers} "
        "--sample_with_n_markers_after_filt {params.sample_with_n_markers_after_filt} "
        "--mutation_rates"

#######################################
# extract the markers for StrainPhlAn #
#######################################
rule extract_markers:
    input:
        consensus_markers_dir   = rules.sample2markers.output.consensus_markers_dir,
        clades_list             = rules.StrainPhlAn_get_SGB.output.clades_list
    output:
        clade_markers           = RESULT_DIR + "StrainPhlAn/clade_markers/{clade}/{clade}.fna"
    params:
        database                = config["MetaPhlAn4_profiling"]["bowtie2db"] + config["MetaPhlAn4_profiling"]["index"] + ".pkl"
    conda:
        "metaphlan_env"
    message:
        "Extracting the markers from the consensus-marker files for clade {wildcards.clade}"
    shell:
        "mkdir -p $(dirname '{output.clade_markers}'); "
        "extract_markers.py "
        "--clades {wildcards.clade} "
        "--database {params.database} "
        "--output_dir $(dirname '{output.clade_markers}')"

#####################################################################
# StrainPhlAn profiling of the composition of microbial communities #
#####################################################################
rule StrainPhlAn_profiling:
    input:
        consensus_markers       = rules.sample2markers.output.markers_outputs,
        clade_markers           = rules.extract_markers.output.clade_markers
    output:
        alignments              = directory(RESULT_DIR + "StrainPhlAn/alignments/{clade}/"),
        best_tree               = RESULT_DIR + "StrainPhlAn/alignments/{clade}/RAxML_bestTree.{clade}.StrainPhlAn4.tre"
    params:
        reference_genomes       = config["StrainPhlAn"]["reference_genomes"],
        database                = config["MetaPhlAn4_profiling"]["bowtie2db"] + config["MetaPhlAn4_profiling"]["index"] + ".pkl",
        marker_in_n_samples     = config["StrainPhlAn"]["marker_in_n_samples"],
        sample_with_n_markers   = config["StrainPhlAn"]["sample_with_n_markers"],
        phylophlan_mode         = config["StrainPhlAn"]["phylophlan_mode"]
    conda:
        "metaphlan_env"
    message:
        "Strain level profiling {wildcards.clade}"
    shell:
        "mkdir -p {output.alignments}; "
        "strainphlan "
        "--samples {input.consensus_markers} "
        "--database {params.database} "
        "--clade_markers {input.clade_markers} "
        "--clade {wildcards.clade} "
        "--output_dir {output.alignments} "
        "--nprocs {resources.cpus_per_task} "
        "--phylophlan_mode {params.phylophlan_mode} "
        "--marker_in_n_samples {params.marker_in_n_samples} "
        "--sample_with_n_markers {params.sample_with_n_markers}"

#############################
# StrainPhlAn Visualization #
#############################
rule StrainPhlAn_visualization:
    input:
        tree = RESULT_DIR + "StrainPhlAn/alignments/{clade}/RAxML_bestTree.{clade}.StrainPhlAn4.tre",
        alignment = RESULT_DIR + "StrainPhlAn/alignments/{clade}/{clade}.StrainPhlAn4_concatenated.aln",
        metadata = config["refs"]["samples"]
    output:
        tree1 = RESULT_DIR + "StrainPhlAn/visualizations/{clade}_tree_1.png",
        tree2 = RESULT_DIR + "StrainPhlAn/visualizations/{clade}_tree_2.png"
    conda:
        "metaphlan_env"
    message:
        "Creating visualization for {wildcards.clade}"
    shell:
        "Rscript scripts/strainphlan_ggtree_vis.R "
        "{input.tree} "
        "{input.metadata} "
        "{input.alignment} "
        "{output.tree1} "
        "{output.tree2}"