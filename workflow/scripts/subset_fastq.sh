#!/bin/bash

# Check if correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    echo "Example: $0 /path/to/input/fastq/files /path/to/output/directory"
    exit 1
fi

# Store input and output directories
INPUT_DIR=$1
OUTPUT_DIR=$2

# Check if input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory $INPUT_DIR does not exist"
    exit 1
fi

# Check if output directory exists, if not create it
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Creating output directory $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi

# Check if seqtk is installed
if ! command -v seqtk &> /dev/null; then
    echo "Error: seqtk is not installed or not in PATH"
    exit 1
fi

# Count total number of fastq.gz files
total_files=$(ls ${INPUT_DIR}/*.fastq.gz 2>/dev/null | wc -l)
if [ "$total_files" -eq 0 ]; then
    echo "No .fastq.gz files found in $INPUT_DIR"
    exit 1
fi

echo "Found $total_files fastq.gz files to process"
echo "Starting subsetting to 5%..."

# Counter for processed files
counter=0

# Process each fastq.gz file
for file in ${INPUT_DIR}/*.fastq.gz; do
    # Get just the filename without the path
    filename=$(basename "$file")
    # Create output filename
    outfile="${OUTPUT_DIR}/${filename%.fastq.gz}_subset.fastq.gz"
    
    # Increment counter
    ((counter++))
    
    echo "Processing file $counter of $total_files: $filename"
    
    # Subset the file using seqtk
    zcat "$file" | seqtk sample -s100 - 0.05 | gzip > "$outfile"
    
    echo "Created: $outfile"
done

echo "Completed! All files have been processed."
