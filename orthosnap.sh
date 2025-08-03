#!/bin/bash

# -----------------------------------------------------------------------------
# Script: orthosnap.sh
# Description: Extract single-copy orthologous groups using OrthoSNAP
# Requirements: OrthoSNAP v1.3.2 or later
# -----------------------------------------------------------------------------

# === Define input directories ===
ALIGN_DIR="data/codon_alignments"             # Directory with codon-aware alignments (*.fasta)
TREE_DIR="data/gene_trees_fixed"              # Directory with gene trees (*.treefile)
OUT_BASE="results/orthosnap_output"           # Base output directory for SNAP-OGs

# === Create base output directory ===
mkdir -p "$OUT_BASE"

# === Loop over each alignment file ===
for fasta_file in "$ALIGN_DIR"/*.fasta; do
    # Extract BUSCO ID (filename without extension)
    busco_id=$(basename "$fasta_file" .fasta)

    # Define the corresponding gene tree file
    tree_file="$TREE_DIR/${busco_id}.treefile"

    # Check if the tree file exists
    if [[ ! -f "$tree_file" ]]; then
        echo "Skipping $busco_id — tree file not found"
        continue
    fi

    # Create output directory for this BUSCO
    output_dir="${OUT_BASE}/${busco_id}"
    mkdir -p "$output_dir"

    echo "Running OrthoSNAP for: $busco_id"

    # Run OrthoSNAP
    orthosnap \
        -f "$fasta_file" \
        -t "$tree_file" \
        -o 1 \
        -s 0 \
        -st \
        -ip longest_seq_len \
        -op "$output_dir"

    echo "Completed: $busco_id"
done

echo "All BUSCO orthogroups processed with OrthoSNAP."
