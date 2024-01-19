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
        composition_profile = RESULT_DIR + "MetaPhlAn4_bbmap/profiles/{sample}_metaphlan4.txt",
        bowtie2out          = RESULT_DIR + "MetaPhlAn4_bbmap/bowtie2out/{sample}_bowtie2out_metagenome.bz2",
        sams                = RESULT_DIR + "MetaPhlAn4_bbmap/sams/{sample}.sam.bz2"

    params:
        input_type      = config["MetaPhlAn4_profiling"]["input_type"],
        bowtie2db       = config["MetaPhlAn4_profiling"]["bowtie2db"],
        index           = config["MetaPhlAn4_profiling"]["index"],
        analysis_type   = config["MetaPhlAn4_profiling"]["analysis_type"],
        read_min_length = config["MetaPhlAn4_profiling"]["read_min_length"],
        mapq_threshold  = config["MetaPhlAn4_profiling"]["mapq_threshold"],
        robust_average  = config["MetaPhlAn4_profiling"]["robust_average"]

    message:
        "Profiling the composition of microbial communities in {wildcards.sample} using MetaPhlAn 4"
    threads:
        config["MetaPhlAn4_profiling"]["threads"]
    resources:
        mem_mb = config["MetaPhlAn4_profiling"]["mem_mb"]
    conda: 
        "metaphlan_env"
    shell:
        "mkdir -p {RESULT_DIR}MetaPhlAn4_bbmap/bowtie2out/; "
        "metaphlan "
        "{input.read_1},"
        "{input.read_2} "
        "-s {output.sams} "
        "--bowtie2out {output.bowtie2out} "
        "--nproc {threads} "
        "--input_type {params.input_type} "
        "--index {params.index} "
        "--bowtie2db {params.bowtie2db} "
        "-t {params.analysis_type} "
        "--add_viruses "
        "--stat_q {params.robust_average} "
        "--read_min_len {params.read_min_length} "
        "--min_mapq_val {params.mapq_threshold} "
        "--output_file {output.composition_profile}"

############################################
# Merging MetaPhlAn 4 composition profiles #
############################################
rule MetaPhlAn4_bbmap_merging:
    input:
        composition_profiles = expand(rules.MetaPhlAn4_bbmap_profiling.output.composition_profile, sample = SAMPLES)
    output:
        merged_report = RESULT_DIR + "merged_csv_files/Metaphlan4_Bbmap_merged.csv"
    params:
        file_dir    = RESULT_DIR + "MetaPhlAn4_bbmap/profiles/",
        output_file = "Metaphlan4_Bbmap_merged.csv",
        output_dir = RESULT_DIR + "merged_csv_files/"
    message:
        "Merging MetaPhlAn 4 composition profiles"
    conda: 
        "metaphlan_env"
    shell:
        "python3 scripts/metaphlan4_merging.py "
        "{params.file_dir} "
        "{params.output_dir} "
        "{params.output_file}"
