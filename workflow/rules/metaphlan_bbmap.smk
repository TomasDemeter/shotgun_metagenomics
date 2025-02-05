#####################################################################
# MetaPhlAn 4 profiling of the composition of microbial communities #
#####################################################################
rule MetaPhlAn4_bbmap_profiling:
    input:
        read_1              = rules.bbmap_default.output.unmapped1,
        read_2              = rules.bbmap_default.output.unmapped2,
        metaphlan_bowtie2db = rules.MetaPhlAn4_build.output.metaphlan_bowtie2db
    output:
        composition_profile = RESULT_DIR + "MetaPhlAn4_bbmap/profiles/{sample}_metaphlan4.txt",
        bowtie2out          = RESULT_DIR + "MetaPhlAn4_bbmap/bowtie2out/{sample}_bowtie2out_metagenome.bz2",
        sams                = RESULT_DIR + "MetaPhlAn4_bbmap/sams/{sample}.sam.bz2"
    params:
        input_type          = config["MetaPhlAn4_profiling"]["input_type"],
        bowtie2db           = config["MetaPhlAn4_profiling"]["bowtie2db"],
        index               = config["MetaPhlAn4_profiling"]["index"],
        analysis_type       = config["MetaPhlAn4_profiling"]["analysis_type"],
        read_min_length     = config["MetaPhlAn4_profiling"]["read_min_length"],
        mapq_threshold      = config["MetaPhlAn4_profiling"]["mapq_threshold"],
        robust_average      = config["MetaPhlAn4_profiling"]["robust_average"]

    message:
        "Profiling the composition of microbial communities in {wildcards.sample} using MetaPhlAn 4"
    conda: 
        "metaphlan_env"
    shell:
        "mkdir -p {RESULT_DIR}MetaPhlAn4_bbmap/bowtie2out/; "
        "metaphlan "
        "{input.read_1},"
        "{input.read_2} "
        "-s {output.sams} "
        "--bowtie2out {output.bowtie2out} "
        "--nproc {resources.cpus_per_task} "
        "--input_type {params.input_type} "
        "--index {params.index} "
        "--bowtie2db {params.bowtie2db} "
        "-t {params.analysis_type} "
        "--stat_q {params.robust_average} "
        "--read_min_len {params.read_min_length} "
        "--min_mapq_val {params.mapq_threshold} "
        "--output_file {output.composition_profile}"


################################################
# Generating csv style reports from Metaphlan4 #
################################################
rule metaphlan4processing_bbmap:
    input:
        profiles                    = expand(rules.MetaPhlAn4_bbmap_profiling.output.composition_profile, sample = SAMPLES)
    output:
        merged_metaphlan4_report    = config["MetaPhlAn4_profiling"]["csv_output_merged"] + "Metaphlan4_BBmap_report.csv"
    params:
        reports                     = RESULT_DIR + "MetaPhlAn4_bbmap/profiles/"    
    conda:
        "kraken2_env"
    message:
        "Converting Metaphlan4 txt reports to csv merged report"
    shell:
        "python3 scripts/metaphlan4_processing.py "
        "{params.reports} "
        "{output.merged_metaphlan4_report}"
