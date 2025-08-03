#!/bin/bash

# -----------------------------------------------------------------------------
# Script: run_speciesrax.sh
# Description: Run SpeciesRax on a set of BUSCO gene trees and mapping files
# Requirements: GeneRax v2.1.3, MPI (e.g., OpenMPI), valid species tree and mappings
# -----------------------------------------------------------------------------

# === Load required tools ===
# Adjust this path if GeneRax is installed elsewhere
export PATH="/services/tools/generax/2.1.3/bin:$PATH"

# === User-defined paths ===
MAPPING_DIR="data/mappings"                     # Directory containing *.mapping files
TREE_DIR="data/gene_trees"                      # Directory containing *.treefile gene trees
OUTPUT_DIR="results/speciesrax_output"          # Output directory for SpeciesRax
FAMILIES_FILE="data/families_speciesrax.txt"    # Families config file for SpeciesRax
GENERAX_EXEC="generax"                          # GeneRax executable
SPECIES_TREE="data/species_tree_cleaned.tre"    # Starting species tree
CORES=20                                        # Number of CPU cores to use

# === Create output directory ===
mkdir -p "$OUTPUT_DIR"
mkdir -p "$(dirname "$FAMILIES_FILE")"

# === Step 1: Build the families_speciesrax.txt configuration file ===
echo "[FAMILIES]" > "$FAMILIES_FILE"

for map_file in "$MAPPING_DIR"/*.mapping; do
  [ -f "$map_file" ] || continue
  BUSCO=$(basename "$map_file" .mapping)
  TREE_FILE="$TREE_DIR/$BUSCO.treefile"

  if [ ! -f "$TREE_FILE" ]; then
    echo "Skipping $BUSCO (treefile missing)"
    continue
  fi

  echo "- $BUSCO" >> "$FAMILIES_FILE"
  echo "starting_gene_tree = $TREE_FILE" >> "$FAMILIES_FILE"
  echo "mapping = $map_file" >> "$FAMILIES_FILE"
  echo "" >> "$FAMILIES_FILE"
done

echo "Families file created: $FAMILIES_FILE"

# === Step 2: Run SpeciesRax ===
echo "Running SpeciesRax..."

mpiexec -np "$CORES" "$GENERAX_EXEC" \
  --families "$FAMILIES_FILE" \
  --species-tree "$SPECIES_TREE" \
  --strategy SKIP \
  --rec-model UndatedDTL \
  --per-family-rates \
  --prune-species-tree \
  --si-estimate-bl \
  --si-quartet-support \
  --prefix "$OUTPUT_DIR/speciesrax" \
  --si-strategy HYBRID

echo "SpeciesRax run complete. Results in: $OUTPUT_DIR"
