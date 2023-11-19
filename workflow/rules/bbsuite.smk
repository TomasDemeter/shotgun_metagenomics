#########################
# DNA-seq read trimming #
#########################
rule bbduk:
    input:
        read_1 = WORKING_DIR + "raw_reads/{ERR}_1.fastq.gz",
        read_2 = WORKING_DIR + "raw_reads/{ERR}_2.fastq.gz"
    output:
        output_1    = WORKING_DIR + "BBsuite/BBduk/{ERR}_1.fastq.gz",
        output_2    = WORKING_DIR + "BBsuite/BBduk/{ERR}_2.fastq.gz",
        stats       = WORKING_DIR + "BBsuite/logs/bbduk/{ERR}_bbduk_report.txt" 
    message:
        "trimming {wildcards.ERR} reads"
    threads:
        config["bbduk"]["threads"]
    conda: 
        "bbmap"
    params:
        quality_treshold    = config["bbduk"]["trim_quality"],
        trimming_side       = config["bbduk"]["trim_side"],
        kmer_size           = config["bbduk"]["kmer_size"],
        hdist               = config["bbduk"]["hdist"],
        adapters            = config["refs"]["adapters"]
    shell:
        "mkdir -p {WORKING_DIR}BBsuite/logs/bbduk; "
        "bbduk.sh "
        "in1={input.read_1} "
        "in2={input.read_2} "
        "out1={output.output_1} "
        "out2={output.output_2} "
        "trimq={params.quality_treshold} "
        "ktrim={params.trimming_side} "
        "k={params.kmer_size} "
        "hdist={params.hdist} "
        "ref={params.adapters} "
        "stats={output.stats} "
        "tbo "
        "tpe"

#########################
# Filtering human reads #
#########################
rule bbmap_coarse:
    input:
        read_1 = rules.bbduk.output.output_1,
        read_2 = rules.bbduk.output.output_2
    output:
        mapped_to_human1    = WORKING_DIR + "BBsuite/BBmap/{ERR}_human1.fq.gz", # temp
        mapped_to_human2    = WORKING_DIR + "BBsuite/BBmap/{ERR}_human2.fq.gz", # temp
        unmapped1           = WORKING_DIR + "BBsuite/BBmap/{ERR}_unmapped1_coarse.fq.gz", # temp
        unmapped2           = WORKING_DIR + "BBsuite/BBmap/{ERR}_unmapped2_coarse.fq.gz", # temp
        stats               = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_statsfile_coarse.txt"
    message:
        "filtering human sequences in {wildcards.ERR} using BBmap coarse parameters"
    threads:
        config["bbmap"]["threads"]
    conda: 
        "bbmap"
    params:
        human_genome    = config["refs"]["human_genome"],
        fast            = config["bbmap"]["fast"],
        minratio        = config["bbmap"]["minratio"],
        maxindel        = config["bbmap"]["maxindel"],
        kmer_length     = config["bbmap"]["k"]
        
    shell:
        "mkdir -p {WORKING_DIR}BBsuite/BBmap; "
        "bbmap.sh "
        "threads={threads} "
        "in1={input.read_1} "
        "in2={input.read_2} "
        "outm1={output.mapped_to_human1} "
        "outm2={output.mapped_to_human2} "
        "outu1={output.unmapped1} "
        "outu2={output.unmapped2} "
        "statsfile={output.stats} "
        "ref={params.human_genome}"

rule bbmap_default:
    input:
        read_1 = rules.bbmap_coarse.output.unmapped1,
        read_2 = rules.bbmap_coarse.output.unmapped2
    output:
        mapped_to_human1    = WORKING_DIR + "BBsuite/BBmap/{ERR}_human1.fq.gz",
        mapped_to_human2    = WORKING_DIR + "BBsuite/BBmap/{ERR}_human2.fq.gz",
        unmapped1           = WORKING_DIR + "BBsuite/BBmap/{ERR}_unmapped1.fq.gz",
        unmapped2           = WORKING_DIR + "BBsuite/BBmap/{ERR}_unmapped2.fq.gz",
        stats               = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_statsfile.txt",
        bhist               = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_bhist.txt",
        aqhist              = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_aqhist.txt",
        lhist               = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_lhist.txt",
        ihist               = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_ihist.txt",
        ehist               = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_ehist.txt",
        qahist              = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_qahist.txt",
        indelhist           = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_indelhist.txt",
        mhist               = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_mhist.txt",
        gchist              = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_gchist.txt",
        idhist              = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_idhist.txt",
        scafstats           = WORKING_DIR + "BBsuite/logs/bbmap/{ERR}_scafstats.txt"
    message:
        "filtering human sequences in {wildcards.ERR} using BBmap default parameters"
    threads:
        config["bbmap"]["threads"]
    params:
        human_genome    = config["refs"]["human_genome"]
    conda: 
        "bbmap"
    shell:
        "mkdir -p {WORKING_DIR}BBsuite/BBmap; "
        "bbmap.sh "
        "threads={threads} "
        "in1={input.read_1} "
        "in2={input.read_2} "
        "outm1={output.mapped_to_human1} "
        "outm2={output.mapped_to_human2} "
        "outu1={output.unmapped1} "
        "outu2={output.unmapped2} "
        "ref={params.human_genome} "
        "statsfile={output.stats} "
        "bhist={output.bhist} "
        "aqhist={output.aqhist} "
        "lhist={output.lhist} "
        "ihist={output.ihist} "
        "ehist={output.ehist} "
        "qahist={output.qahist} "
        "indelhist={output.indelhist} "
        "mhist={output.mhist} "
        "gchist={output.gchist} "
        "idhist={output.idhist} "
        "scafstats={output.scafstats}"
