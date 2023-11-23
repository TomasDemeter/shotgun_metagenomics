##################
# MultiQC report #
##################
rule multiqc:
    input:
        #bbduk_input         = expand(rules.bbduk.output.stats, ERR=SAMPLES),
        #bbmap_input         = expand(rules.bbmap_default.output.stats, ERR=SAMPLES),
        fastp_input_html    = expand(rules.fastp.output.html, ERR=SAMPLES),
        fastp_input_json    = expand(rules.fastp.output.json, ERR=SAMPLES),
        bowtie_input        = expand(rules.bowtie2_mapping.output.logs, ERR=SAMPLES),
    output:
        outdir      = directory(RESULT_DIR + "MultiQC/"),
        output      = RESULT_DIR + "MultiQC/multiqc_report.html"
    params:
        #bbduk_logs  = WORKING_DIR + "BBsuite/logs/bbduk/",
        #bbmap_plots = WORKING_DIR + "BBsuite/logs/bbmap/",
        fastp_logs  = WORKING_DIR + "fastp/logs/",
        bowtie_logs = WORKING_DIR + "Bowtie2/logs/",
    conda: 
        "multiqc_env"
    message: "Summarising bbduk and bbmap reports with multiqc"
    shell:
        "mkdir -p {output.outdir}; "
        "multiqc "
        "--force "
        "--outdir {output.outdir} "
        "{params.fastp_logs} "
        "{params.bowtie_logs}"
        #"{params.bbduk_logs} "
        #"{params.bbmap_plots}"
