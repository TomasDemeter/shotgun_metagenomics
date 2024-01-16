#!/bin/bash

# Check if both arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <input.tsv> <output_dir>"
    exit 1
fi

input_file=$1
output_dir=$2

# Check if input file exists
if [ ! -f $input_file ]; then
    echo "Input file not found: $input_file"
    exit 1
fi

# Check if output directory exists, if not create it
if [ ! -d $output_dir ]; then
    mkdir -p $output_dir
fi

# Process the input file and download fasta files using the accession number
for accession in $(awk 'NR > 1 {print $1}' "$input_file")
do
    echo "Processing accession: $accession"

    esearch -db nucleotide -query $accession \
    | efetch -format fasta > "$output_dir/$accession.fasta"
    if [ $? -ne 0 ]; then
        echo "Error downloading file: $accession"
        exit 1
    fi

    # Compress the output file
    bzip2 "$output_dir/$accession.fasta"

    sleep 1 # wait for 3 seconds to avoid rate limiting
done

echo "Processing completed."