#!/bin/bash

# -----------------------------------------------------------------------------
# Script: disco.sh
# Description: Decompose multicopy gene trees using DISCO into single-copy orthologs
# Requirements: DISCO (v1.4.1), TreeSwift, Python 3
# -----------------------------------------------------------------------------

# === Activate conda environment with DISCO installed ===
# Make sure environment has DISCO and TreeSwift
# e.g., conda create -n pca_env python=3.10 treeswift -c bioconda
source ~/.bashrc
conda activate "environment"

# === Define input/output directories ===
INPUT_DIR="data/gene_trees_fixed"         # Input directory with *.treefile gene trees
OUTPUT_DIR="results/disco_output"         # Output directory for single-copy trees
DELIMITER="|"                             # Delimiter used in taxon labels

# === Create output directory if needed ===
mkdir -p "$OUTPUT_DIR"

# === Loop through each tree file and run DISCO ===
for treefile in "$INPUT_DIR"/*.treefile; do
    base=$(basename "$treefile" .treefile)
    outfile="${OUTPUT_DIR}/${base}_single.treefile"

    # Run DISCO decomposition
    python3 disco.py \
        -i "$treefile" \
        -o "$outfile" \
        -d "$DELIMITER" \
        --single_tree \
        --keep-labels \
        --remove_in_paralogs \
        --verbose

    echo "Processed: $treefile → $outfile"
done

echo "All gene trees processed with DISCO."
