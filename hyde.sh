#!/bin/bash

# -----------------------------------------------------------------------------
# Script:hyde.sh
# Description: Batch-run HyDe across multiple PHYLIP alignments and triples
# Requirements: HyDe (run_hyde_mp.py), Python 3.6+, properly formatted input files
# -----------------------------------------------------------------------------

# === Input directories ===
PHY_DIR="data/hyde/phylip_alignments"                  # Directory containing .phy alignments
MAP_DIR="data/hyde/sample_mappings"                    # Sample-to-species mapping files
TRIPLES_DIR="data/hyde/triplets"                       # Triplet combinations per alignment
OUTGROUP="ASM4671857v1_Chenopodium_vulvaria"           # Outgroup taxon label
THREADS=10                                             # Number of threads per run

# === Output directory ===
OUTPUT_DIR="results/hyde_runs"
mkdir -p "$OUTPUT_DIR"

# === Loop through .phy alignments ===
for PHY_FILE in "$PHY_DIR"/*.phy; do
    BASENAME=$(basename "$PHY_FILE" .phy)
    MAP_FILE="${MAP_DIR}/${BASENAME}_mapping.txt"
    TRIPLES_FILE="${TRIPLES_DIR}/${BASENAME}_triples.txt"
    OUT_PREFIX="${OUTPUT_DIR}/${BASENAME}"

    # Check for required input files
    if [[ ! -f "$MAP_FILE" ]]; then
        echo "Skipping $BASENAME — missing mapping file"
        continue
    fi
    if [[ ! -f "$TRIPLES_FILE" ]]; then
        echo "Skipping $BASENAME — missing triples file"
        continue
    fi

    # Extract alignment dimensions
    NUM_TAXA=$(awk 'NR==1 {print $1}' "$PHY_FILE")
    NUM_SITES=$(awk 'NR==1 {print $2}' "$PHY_FILE")
    NUM_INDIV=$(awk 'NR > 1 && NF > 1 {count++} END {print count}' "$PHY_FILE")

    echo "Running HyDe for $BASENAME ($NUM_TAXA taxa, $NUM_INDIV individuals, $NUM_SITES sites)"

    # Run HyDe
    run_hyde_mp.py \
        -i "$PHY_FILE" \
        -m "$MAP_FILE" \
        -o "$OUTGROUP" \
        -n "$NUM_INDIV" \
        -t "$NUM_TAXA" \
        -s "$NUM_SITES" \
        -tr "$TRIPLES_FILE" \
        -j "$THREADS" \
        --prefix "$OUT_PREFIX" \
        --ignore_amb_sites

    echo "Finished HyDe for $BASENAME"
done

echo "All HyDe analyses completed."
