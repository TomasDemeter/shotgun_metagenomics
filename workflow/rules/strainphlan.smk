####################
# python functions #
####################

# read output of StrainPhlAn_get_SGB to get the clades 
def get_all_clades(clades_file):
    with open(clades_file, 'r') as f:
        # Skip the header line
        next(f)
        # Read only the first column, strip whitespace
        return [line.split('\t')[0].strip() for line in f if line.strip()]



##########################################################################
# Produce the consensus-marker files which are the input for StrainPhlAn #
##########################################################################
rule sample2markers:
    input:
        metaphlan_inputs        = expand(RESULT_DIR + "MetaPhlAn4/sams/{sample}.sam.bz2", sample=config["StrainPhlAn"]["strainphlan_samples"])
    output:
        consensus_markers_dir   = directory(RESULT_DIR + "StrainPhlAn/consensus_markers/"),
        markers_outputs         = expand(RESULT_DIR + "StrainPhlAn/consensus_markers/{sample}.pkl", sample=config["StrainPhlAn"]["strainphlan_samples"])
    params:
        database                = config["MetaPhlAn4_profiling"]["bowtie2db"] + config["MetaPhlAn4_profiling"]["index"] + ".pkl"
    conda:
        "metaphlan_env"
    message:
        "Producing the consensus-marker files which are the input for StrainPhlAn"
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
rule StrainPhlAn_get_SGB:
    input:
        consensus_markers = rules.sample2markers.output.markers_outputs,
    output:
        clades_list = RESULT_DIR + "StrainPhlAn/alignments/print_clades_only.tsv"
    params:
        alignments_dir = RESULT_DIR + "StrainPhlAn/alignments/",
        database = config["MetaPhlAn4_profiling"]["bowtie2db"] + config["MetaPhlAn4_profiling"]["index"] + ".pkl",
        mutation_rates = config["StrainPhlAn"]["mutation_rates"],
        marker_in_n_samples = config["StrainPhlAn"]["marker_in_n_samples"],
        sample_with_n_markers = config["StrainPhlAn"]["sample_with_n_markers"],
        sample_with_n_markers_after_filt = config["StrainPhlAn"]["sample_with_n_markers_after_filt"]
    conda:
        "metaphlan_env"
    message:
        "Producing the SGB files using StrainPhlAn"
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

rule all_clades:
    input:
        clades_list = rules.StrainPhlAn_get_SGB.output.clades_list,
    output:
        clade_markers_done = touch(RESULT_DIR + "StrainPhlAn/clade_markers.done")
    run:
        clades = get_all_clades(input.clades_list)
        clade_markers_dir = RESULT_DIR + "StrainPhlAn/clade_markers/"
        shell("mkdir -p {clade_markers_dir}")
        for clade in clades:
            shell("touch {clade_markers_dir}/{clade}.fna")

#######################################
# extract the markers for StrainPhlAn #
#######################################
rule extract_markers:
    input:
        consensus_markers_dir = rules.sample2markers.output.consensus_markers_dir,
        clades_list = rules.StrainPhlAn_get_SGB.output.clades_list,
        clade_markers_done = rules.all_clades.output.clade_markers_done
    output:
        clade_markers = RESULT_DIR + "StrainPhlAn/clade_markers/{clade}.fna"
    params:
        database = config["MetaPhlAn4_profiling"]["bowtie2db"] + config["MetaPhlAn4_profiling"]["index"] + ".pkl"
    conda:
        "metaphlan_env"
    message:
        "Extracting the markers from the consensus-marker files for clade {wildcards.clade}"
    shell:
        "extract_markers.py "
        "--clades {wildcards.clade} "
        "--database {params.database} "
        "--output_dir $(dirname '{output.clade_markers}')"


#####################################################################
# StrainPhlAn profiling of the composition of microbial communities #
#####################################################################
rule StrainPhlAn_profiling:
    input:
        consensus_markers = rules.sample2markers.output.markers_outputs,
        clade_markers = RESULT_DIR + "StrainPhlAn/clade_markers/{clade}.fna"
    output:
        alignments = directory(RESULT_DIR + "StrainPhlAn/alignments/{clade}/")
    params:
        reference_genomes = config["StrainPhlAn"]["reference_genomes"],
        database = config["MetaPhlAn4_profiling"]["bowtie2db"] + config["MetaPhlAn4_profiling"]["index"] + ".pkl",
        mutation_rates = config["StrainPhlAn"]["mutation_rates"],
        marker_in_n_samples = config["StrainPhlAn"]["marker_in_n_samples"],
        sample_with_n_markers = config["StrainPhlAn"]["sample_with_n_markers"],
        phylophlan_mode = config["StrainPhlAn"]["phylophlan_mode"]
    conda:
        "metaphlan_env"
    message:
        "Producing the consensus-marker files which are the input for StrainPhlAn for clade {wildcards.clade}"
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