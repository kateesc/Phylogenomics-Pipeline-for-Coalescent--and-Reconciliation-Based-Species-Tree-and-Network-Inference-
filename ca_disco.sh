#!/bin/bash

# -----------------------------------------------------------------------------
# Script: ca_disco.sh
# Description: Run CA-DISCO to concatenate alignments guided by gene trees
# Requirements: DISCO (v1.4.1), Python 3, Biopython, TreeSwift
# -----------------------------------------------------------------------------

# === Activate Conda environment ===
source ~/.bashrc
conda activate "environment"

# === Define input paths ===
GENE_TREE_FILE="data/disco/gene.trees"                         # Concatenated gene trees (DISCO output)
ALIGN_LIST="data/disco/align_list_with_models.csv"             # CSV: gene_id, alignment_path, model
CA_DISCO_SCRIPT="tools/disco/ca_disco.py"                      # Path to ca_disco.py script
DELIMITER="|"                                                  # Taxon name delimiter
FORMAT="fasta"                                                 # Alignment format (e.g., fasta, phylip)

# === Output paths ===
OUTPUT_ALIGNMENT="results/disco/ca_disco_output.fasta"
PARTITION_FILE="results/disco/ca_disco_output.partitions.txt"

# === Ensure output directory exists ===
mkdir -p "$(dirname "$OUTPUT_ALIGNMENT")"

# === Remove any previous output ===
rm -f "$OUTPUT_ALIGNMENT" "$PARTITION_FILE"

# === Diagnostics ===
echo "Checking Python environment..."
python -c "import Bio; print('Biopython version:', Bio.__version__)"
python -c "import treeswift; print('TreeSwift works:', hasattr(treeswift, 'read_tree_newick'))"

# === Run CA-DISCO ===
echo "Running CA-DISCO..."
python "$CA_DISCO_SCRIPT" \
    -i "$GENE_TREE_FILE" \
    -a "$ALIGN_LIST" \
    -f "$FORMAT" \
    -o "$OUTPUT_ALIGNMENT" \
    -d "$DELIMITER" \
    -p

# === Final status ===
if [[ $? -eq 0 ]]; then
    echo "CA-DISCO completed successfully!"
    echo "Output alignment: $OUTPUT_ALIGNMENT"
    echo "Partition file: $PARTITION_FILE"
else
    echo "CA-DISCO failed!" >&2
    exit 1
fi
