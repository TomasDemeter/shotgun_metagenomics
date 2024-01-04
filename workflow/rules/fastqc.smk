############################################
# Running FastQC on raw and filtered reads #
############################################
rule FastQC:
    input:
        trimmed_read_1  = rules.fastp.output.trimmed_1,
        trimmed_read_2  = rules.fastp.output.trimmed_2
    output:
        html_1        = WORKING_DIR + "FastQC/{sample}_1_fastqc.html",
        zip_file_1    = WORKING_DIR + "FastQC/{sample}_1_fastqc.zip",
        html_2        = WORKING_DIR + "FastQC/{sample}_2_fastqc.html",
        zip_file_2    = WORKING_DIR + "FastQC/{sample}_2_fastqc.zip"        
    params:
        installation_dir = config["FastQC"]["installation_dir"],
        output_dir  = directory(WORKING_DIR + "FastQC/")        
    message:
        "Running FastQC on raw and trimmed files"
    conda: 
        "multiqc_env"
    threads:
        config["FastQC"]["threads"]
    resources:
        mem_mb = config["FastQC"]["mem_mb"]
    shell:
        "mkdir -p {params.output_dir}; "
        "{params.installation_dir}/fastqc "
        "{input.trimmed_read_1} {input.trimmed_read_2} "
        "--outdir {params.output_dir} "
        "--threads {threads} "
        "--memory {resources.mem_mb}"
