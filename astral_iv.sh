#!/bin/bash

# -----------------------------------------------------------------------------
# Script: astral_iv.sh
# Description: Run ASTRAL-IV on gene trees from DISCO using a mapping file
# Requirements: ASTRAL-IV (20250224 or later), Java 11+, valid gene tree and mapping files
# -----------------------------------------------------------------------------

# === User-defined input paths ===
GENE_TREES_FILE="data/disco/gene.trees"                      # Input: multi-labeled gene trees
MAPPING_FILE="data/disco/species_mapping.txt"                # Input: taxon-to-species mapping
OUTPUT_TREE="results/astral_iv/species_tree_astral4.tre"     # Output: species tree
THREADS=40                                                    # Number of threads to use

# === Create output directory ===
mkdir -p "$(dirname "$OUTPUT_TREE")"

# === Check input files ===
if [[ ! -s "$GENE_TREES_FILE" ]]; then
  echo "Gene trees file not found or empty: $GENE_TREES_FILE" >&2
  exit 1
fi

if [[ ! -s "$MAPPING_FILE" ]]; then
  echo "Mapping file not found or empty: $MAPPING_FILE" >&2
  exit 1
fi

# === Run ASTRAL-IV ===
echo "Running ASTRAL-IV..."
astral4 \
  -i "$GENE_TREES_FILE" \
  -a "$MAPPING_FILE" \
  -o "$OUTPUT_TREE" \
  -u 2 \
  -v 2 \
  -t "$THREADS" \
  --seed 42

# === Final status check ===
if [[ $? -eq 0 ]]; then
  echo "ASTRAL-IV completed successfully."
  echo "Output species tree saved to: $OUTPUT_TREE"
else
  echo "ASTRAL-IV run failed!" >&2
  exit 1
fi
