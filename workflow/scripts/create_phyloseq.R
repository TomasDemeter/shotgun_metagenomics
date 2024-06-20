# Load necessary libraries
library(phyloseq)
library(microbiome)
library(tidyverse)
library(optparse)

# Define options for command line arguments
option_list <- list(
  make_option(c("-r", "--report_dir"), type = "character", default = NULL,
              help = "Directory containing report CSV files"),
  make_option(c("-m", "--metadata_path"), type = "character", default = NULL,
              help = "Path to the metadata CSV file"),
  make_option(c("-o", "--output_dir"), type = "character", default = NULL,
              help = "Directory to save output RDS files")
)

# Parse options
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# Function to read and prepare metadata
metadata_preparation <- function(metadata_path, classifier) {
  metadata <- read.csv(metadata_path, header = TRUE, row.names = 1) %>%
    rename(sample_name = colnames(.)) %>%
    mutate(classifier = classifier) %>%
    sample_data()
  
  return(metadata)
}

# Function to create phyloseq object
create_phyloseq <- function(counts, metadata) {
  prepare_counts <- function(counts) {
    counts <- counts %>%
      select(-relative_abundance) %>%
      filter(domain == "Bacteria") %>%
      spread(key = sample, value = reads_from_clade, fill = 0) %>%
      mutate(rowname = paste0("otu", row_number())) %>%
      column_to_rownames("rowname")
    
    return(counts)
  }
  
  prepare_taxa <- function(counts) {
    taxa <- counts %>%
      select(domain, phylum, class, order, family, genus, species) %>%
      mutate(across(everything(), ~na_if(., ""))) %>% 
      as.matrix() %>%
      tax_table()
    
    return(taxa)
  }
  
  prepare_otu <- function(counts, metadata) {
    otu <- counts %>%
      select(which(colnames(.) %in% rownames(metadata))) %>%
      as.matrix() %>%
      otu_table(taxa_are_rows = TRUE)
    
    return(otu)
  }
  
  counts <- prepare_counts(counts)
  taxa <- prepare_taxa(counts)
  otu <- prepare_otu(counts, metadata)
  
  phyloseq_object <- phyloseq(otu, taxa, metadata)
  
  return(phyloseq_object)
}

# Main function to process files and create phyloseq objects
main <- function() {
  # List all CSV files in the report files directory
  report_files <- list.files(opt$report_dir, pattern = "\\.csv$", full.names = TRUE)
  
  # Process each report file
  for(file_path in report_files) {
    # Read counts from the report file
    counts <- read.csv(file_path, header = TRUE)
    
    # Extract classifier from file name
    file_name <- basename(file_path)
    mapper_classifier <- strsplit(file_name, "_")[[1]]
    classifier <- mapper_classifier[1]
    
    # Prepare metadata
    prepared_metadata <- metadata_preparation(opt$metadata_path, classifier)
    
    # Create phyloseq object
    phyloseq_obj <- create_phyloseq(counts, prepared_metadata)
    
    # Save phyloseq object to RDS file
    output_file_path <- file.path(opt$output_dir, paste0(tools::file_path_sans_ext(basename(file_path)), ".rds"))
    saveRDS(phyloseq_obj, file = output_file_path)
  }
}

# Execute the main function if the script is run directly
if (!interactive()) {
    main()
}