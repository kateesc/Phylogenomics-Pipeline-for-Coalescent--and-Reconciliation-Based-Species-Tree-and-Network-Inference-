#!/bin/bash

# -----------------------------------------------------------------------------
# Script: phylonet.sh
# Description: Run PhyloNet (v3.8.4) with specified MPL control script
# -----------------------------------------------------------------------------

set -euo pipefail

# === Define paths ===
MPL_SCRIPT="results/phylonet/run_mpl_h3.nexus"
OUTPUT_FILE="results/phylonet/output_h3.nex"

# === Run PhyloNet ===
echo  "Starting PhyloNet inference..."
java -jar /path/to/PhyloNet.jar "$MPL_SCRIPT" > "$OUTPUT_FILE"
echo "PhyloNet complete. Output saved to: $OUTPUT_FILE"
