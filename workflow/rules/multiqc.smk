##################
# MultiQC report #
##################
rule multiqc:
    input:
        bbduk_input         = expand(WORKING_DIR + "BBsuite/logs/bbduk/{ERR}_bbduk_report.txt", ERR = SAMPLES),
        bbmap_input         = expand(WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_statsfile.txt", ERR = SAMPLES),
        fastp_input_html    = expand(WORKING_DIR + "fastp/logs/{ERR}_fastp.html", ERR = SAMPLES),
        fastp_input_json    = expand(WORKING_DIR + "Bowtie/logs/{ERR}_fastp_Log.final.out", ERR = SAMPLES),
        bowtie_input        = expand(WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_statsfile.txt", ERR = SAMPLES),

    output:
        RESULT_DIR + "MultiQC/multiqc_report.html"
    params:
        bbduk_logs  = WORKING_DIR + "BBsuite/logs/bbduk/",
        bbmap_plots = WORKING_DIR + "BBsuite/logs/bbmap/",
        fastp_logs  = WORKING_DIR + "fastp/log/",
        bowtie_logs = WORKING_DIR + "Bowtie/logs/",
        outdir      = RESULT_DIR + "MultiQC/"
    conda: 
        "multiqc_env"
    message: "Summarising bbduk and bbmap reports with multiqc"
    shell:
        "mkdir -p {RESULT_DIR}MultiQC; "
        "multiqc "
        "--force "
        "--outdir {params.outdir} "
        "{params.fastp_logs} "
        "{params.bowtie_logs} "
        "{params.bbduk_logs} "
        "{params.bbmap_plots}"