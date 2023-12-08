'''
If you have installed MetaPhlAn using Anaconda, it is advised to install the database in a folder outside the Conda environment. To do this, run
metaphlan --install --bowtie2db <database folder>
and add the database directory to config.yaml file

If you install the database in a different location, remember to run MetaPhlAn using --bowtie2db <database folder>!
'''


#####################################################################
# MetaPhlAn 4 profiling of the composition of microbial communities #
#####################################################################
rule MetaPhlAn4_bbmap_profiling:
    input:
        read_1 = rules.bbmap_default.output.unmapped1,
        read_2 = rules.bbmap_default.output.unmapped2
    output:
        composition_profile = RESULT_DIR + "MetaPhlAn4_bbmap/{ERR}_metaphlan4.txt",
        bowtie2out          = RESULT_DIR + "MetaPhlAn4_bbmap/bowtie2out/{ERR}_bowtie2out_metagenome.bz2"
    params:
        input_type  = config["MetaPhlAn4_bbmap_profiling"]["input_type"],
        bowtie2db   = config["MetaPhlAn4_bbmap_profiling"]["bowtie2db"],
        index       = config["MetaPhlAn4_bbmap_profiling"]["index"]
    message:
        "Profiling the composition of microbial communities in {wildcards.ERR} using MetaPhlAn 4"
    threads:
        config["MetaPhlAn4_bbmap_profiling"]["threads"]
    resources:
        mem_mb = config["MetaPhlAn4_bbmap_profiling"]["mem_mb"]
    conda: 
        "mpa"
    shell:
        "mkdir -p {RESULT_DIR}MetaPhlAn4_bbmap/bowtie2out/; "
        "metaphlan "
        "{input.read_1},"
        "{input.read_2} "
        "--bowtie2out {output.bowtie2out} "
        "--nproc {threads} "
        "--input_type {params.input_type} "
        "--index {params.index} "
        "--bowtie2db {params.bowtie2db} "
        "--nreads "
        "--output_file {output.composition_profile}"


############################################
# Merging MetaPhlAn 4 composition profiles #
############################################
rule MetaPhlAn4_bbmap_merging:
    input:
        composition_profiles = expand(rules.MetaPhlAn4_bbmap_profiling.output.composition_profile, ERR = SAMPLES)
    output:
        merged_abundance_table = RESULT_DIR + "MetaPhlAn4_bbmap/merged_abundance_table.txt"
    message:
        "Merging MetaPhlAn 4 composition profiles"
    conda: 
        "mpa"
    shell:
        "merge_metaphlan_tables.py "
        "{RESULT_DIR}MetaPhlAn4_bbmap/*_metaphlan4.txt "
        "> {output.merged_abundance_table}"

