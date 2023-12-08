#!/bin/bash
#SBATCH --job-name=kraken2-build
#SBATCH --output=kraken2-build.out
#SBATCH --error=kraken2-build.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=24:00:00
#SBATCH --mem=100G

kraken2-build --standard --threads 32 --db ../../inputs/genomes/kraken2db