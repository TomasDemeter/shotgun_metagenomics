####################################################
# Generating metaphlan style reports from Kraken2 #
####################################################
rule kraken2mpa:
    input:
        report          = rules.kraken2.output.report
    output:
        mpa_report      = RESULT_DIR + "Kraken2/metaphlan_style_reports/{sample}_kraken2_mpa_report.txt"
    params:
        report_style    = config["kraken2"]["report_style"]
    conda:
        "kraken2_env"
    message:
        "Converting Kraken 2 report to MetaPhlAn style report"
    shell:
        "python3 scripts/kraken2mpa_modified.py "
        "--{params.report_style} "
        "-r{input.report} "
        "-o{output.mpa_report}"

#################################################
# Merging Kraken2 reports from multiple samples #
#################################################
rule merge_kraken2:
    input:
        reports         = expand(rules.kraken2mpa.output.mpa_report, sample = SAMPLES)
    params:
        kraken2_dir     = RESULT_DIR + "Kraken2/metaphlan_style_reports/"
    output:
        merged_report   = RESULT_DIR + "Kraken2/metaphlan_style_reports/kraken2_output_merged.csv"
    conda:
        "kraken2_env"
    message:
        "Merging Kraken 2 reports"
    shell:
        "python3 scripts/kraken2_merging.py {params.kraken2_dir}"