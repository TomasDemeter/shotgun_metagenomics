#########################
# DNA-seq read trimming #
#########################

rule bbduk:
    input:
        read_1 = WORKING_DIR + "raw_reads/{sample}_1.fq.gz",
        read_2 = WORKING_DIR + "raw_reads/{sample}_2.fq.gz"
    output:
        output_1    = WORKING_DIR + "BBsuite/BBduk/{sample}_1.fq.gz",
        output_2    = WORKING_DIR + "BBsuite/BBduk/{sample}_2.fq.gz",
        stats       = WORKING_DIR + "BBsuite/logs/bbduk/{sample}_bbduk_report.txt" 
    message:
        "trimming {wildcards.sample} reads with bbduk"
    threads:
        config["bbduk"]["threads"]
    resources:
        mem_mb = config["bbduk"]["mem_mb"]
    conda: 
        "bbsuite_env"
    params:
        quality_treshold    = config["bbduk"]["trim_quality"],
        kmer_trim           = config["bbduk"]["kmer_trim"],
        kmer_size           = config["bbduk"]["kmer_size"],
        hdist               = config["bbduk"]["hdist"],
        mink                = config["bbduk"]["mink"],
        adapters            = config["refs"]["adapters"],
        quality_trim        = config["bbduk"]["quality_trim"]
    shell:
        "mkdir -p {WORKING_DIR}BBsuite/logs/bbduk; "
        "bbduk.sh "
        "in1={input.read_1} "
        "in2={input.read_2} "
        "out1={output.output_1} "
        "out2={output.output_2} "
        "trimq={params.quality_treshold} "
        "ktrim={params.kmer_trim} "
        "qtrim={params.quality_trim} "
        "k={params.kmer_size} "
        "hdist={params.hdist} "
        "ref={params.adapters} "
        "stats={output.stats} "
        "mink={params.mink} "
        "tbo "
        "tpe"

#########################
# Build index for BBmap #
#########################
rule build_bbmap_index:
    input:
        genome = config["refs"]["human_genome"]
    output:
        index = directory(config["refs"]["bbsuite_index"])
    message:
        "building BBmap index for human genome"
    threads:
        config["bbmap"]["threads"]
    resources:
        mem_mb = config["bbmap"]["mem_mb"]
    conda:
        "bbsuite_env"
    shell:
        "mkdir -p {output.index}; "
        "bbmap.sh "
        "threads={threads} "
        "ref={input.genome} "
        "path={output.index}"

################################################
# Filtering human reads with coarse parameters #
################################################
rule bbmap_coarse:
    input:
        read_1 = rules.bbduk.output.output_1,
        read_2 = rules.bbduk.output.output_2,
        index  = rules.build_bbmap_index.output.index
    output:
        unmapped1           = WORKING_DIR + "BBsuite/BBmap/{sample}_unmapped1_coarse.fq.gz",
        unmapped2           = WORKING_DIR + "BBsuite/BBmap/{sample}_unmapped2_coarse.fq.gz",
        stats               = WORKING_DIR + "BBsuite/logs/bbmap_stats/{sample}_statsfile_coarse.txt"
    message:
        "filtering human sequences in {wildcards.sample} using BBmap coarse parameters"
    threads:
        config["bbmap"]["threads"]
    resources:
        mem_mb = config["bbmap"]["mem_mb"]
    conda: 
        "bbsuite_env"
    params:
        mapped_to_human1    = temp(WORKING_DIR + "BBsuite/BBmap/{sample}_human1.fq.gz"),
        mapped_to_human2    = temp(WORKING_DIR + "BBsuite/BBmap/{sample}_human2.fq.gz"),
        fast            = config["bbmap"]["fast"],
        minid           = config["bbmap"]["minid"],
        maxindel        = config["bbmap"]["maxindel"],
        kmer_length     = config["bbmap"]["k"],
        minhits         = config["bbmap"]["minhits"]
        
    shell:
        "mkdir -p {WORKING_DIR}BBsuite/BBmap; "
        "bbmap.sh "
        "threads={threads} "
        "in1={input.read_1} "
        "in2={input.read_2} "
        "outm1={params.mapped_to_human1} "
        "outm2={params.mapped_to_human2} "
        "outu1={output.unmapped1} "
        "outu2={output.unmapped2} "
        "statsfile={output.stats} "
        "path={input.index} "
        "fast={params.fast} "
        "minhits={params.minhits} "
        "k={params.kmer_length} "
        "maxindel={params.maxindel} "
        "minid={params.minid}"

#################################################
# Filtering human reads with default parameters #
#################################################
rule bbmap_default:
    input:
        read_1 = rules.bbmap_coarse.output.unmapped1,
        read_2 = rules.bbmap_coarse.output.unmapped2,
        index  = rules.build_bbmap_index.output.index
    output:
        mapped_to_human1    = WORKING_DIR + "BBsuite/BBmap/{sample}_human1.fq.gz",
        mapped_to_human2    = WORKING_DIR + "BBsuite/BBmap/{sample}_human2.fq.gz",
        unmapped1           = WORKING_DIR + "BBsuite/BBmap/{sample}_unmapped1.fq.gz",
        unmapped2           = WORKING_DIR + "BBsuite/BBmap/{sample}_unmapped2.fq.gz",
        stats               = WORKING_DIR + "BBsuite/logs/bbmap_stats/{sample}_statsfile.txt",
        bhist               = WORKING_DIR + "BBsuite/logs/bbmap/{sample}_bhist.txt",
        aqhist              = WORKING_DIR + "BBsuite/logs/bbmap/{sample}_aqhist.txt",
        lhist               = WORKING_DIR + "BBsuite/logs/bbmap/{sample}_lhist.txt",
        ihist               = WORKING_DIR + "BBsuite/logs/bbmap/{sample}_ihist.txt",
        ehist               = WORKING_DIR + "BBsuite/logs/bbmap/{sample}_ehist.txt",
        qahist              = WORKING_DIR + "BBsuite/logs/bbmap_stats/{sample}_qahist.txt",
        indelhist           = WORKING_DIR + "BBsuite/logs/bbmap/{sample}_indelhist.txt",
        mhist               = WORKING_DIR + "BBsuite/logs/bbmap/{sample}_mhist.txt",
        gchist              = WORKING_DIR + "BBsuite/logs/bbmap/{sample}_gchist.txt",
        idhist              = WORKING_DIR + "BBsuite/logs/bbmap/{sample}_idhist.txt",
        scafstats           = WORKING_DIR + "BBsuite/logs/bbmap/{sample}_scafstats.txt"
    message:
        "filtering human sequences in {wildcards.sample} using BBmap default parameters"
    threads:
        config["bbmap"]["threads"]
    resources:
        mem_mb = config["bbmap"]["mem_mb"],
        time = "2-00:00:00"
    params:
        human_genome    = config["refs"]["human_genome"]
    conda: 
        "bbsuite_env"
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
        "path={input.index} "
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
