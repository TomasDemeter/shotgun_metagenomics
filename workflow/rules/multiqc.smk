##################
# MultiQC report #
##################
rule multiqc:
    input:
        fastp_input_html    = expand(rules.fastp.output.html, sample=SAMPLES),
        fastp_input_json    = expand(rules.fastp.output.json, sample=SAMPLES),
        bowtie_input        = expand(rules.bowtie2_mapping.output.logs, sample=SAMPLES),
        fastqc_input_1      = expand(rules.FastQC.output.zip_file_1, sample=SAMPLES),
        fastqc_input_2      = expand(rules.FastQC.output.zip_file_2, sample=SAMPLES)
    output:
        outdir              = directory(RESULT_DIR + "MultiQC/"),
        output              = RESULT_DIR + "MultiQC/multiqc_report.html"
    params:
        bbduk_logs          = WORKING_DIR + "BBsuite/logs/bbduk/",
        fastp_logs          = WORKING_DIR + "fastp/logs/",
        bowtie_logs         = WORKING_DIR + "Bowtie2/logs/",
        fastqc_zip          = WORKING_DIR + "FastQC/"
    conda: 
        "multiqc_env"
    message: "Summarising reports with multiqc"
    shell:
        "mkdir -p {output.outdir}; "
        "multiqc "
        "--force "
        "--outdir {output.outdir} "
        "{params.fastp_logs} "
        "{params.bowtie_logs} "
        "{params.bbduk_logs} "
        "{params.fastqc_zip}"
