#!/bin/bash

# -----------------------------------------------------------------------------
# Script: make_mpl_script.sh
# Description: Generate PhyloNet NEXUS control script to infer hybridization
# -----------------------------------------------------------------------------

# === User-defined parameters ===
TREE_NEXUS="data/phylonet/gene.trees_chenopodium.nex"   # Input: gene trees in NEXUS format
MPL_SCRIPT="results/phylonet/run_mpl_h3.nexus"          # Output: control script for PhyloNet
OUTPUT_FILE="results/phylonet/output_h3.nex"            # Output: PhyloNet results file
HYBRID_EVENTS=3                                          # Number of hybridization events to test

# === Ensure output directory exists ===
mkdir -p "$(dirname "$MPL_SCRIPT")"

# === Extract tree names from NEXUS block ===
TREE_NAMES=$(grep -oP '^ *Tree +\K\w+' "$TREE_NEXUS" | paste -sd "," -)

# === Write control script ===
cat <<EOF > "$MPL_SCRIPT"
#NEXUS

BEGIN PHYLONET;
  InferNetwork_MPL ($TREE_NAMES) $HYBRID_EVENTS -o $OUTPUT_FILE;
END;
EOF

echo "Control script created: $MPL_SCRIPT"
