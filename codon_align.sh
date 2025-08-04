#!/bin/bash

# -----------------------------------------------------------------------------
# Script: codon_align.sh
# Description: Generate codon-aware nucleotide alignments using amino acid
#              alignments and unaligned nucleotide sequences
# -----------------------------------------------------------------------------

set -euo pipefail

# === Input/Output paths ===
AA_DIR="data/codon_alignment/aa_aligned"                          # Amino acid aligned FASTAs
NT_DIR="data/codon_alignment/nt_unaligned"                        # Nucleotide FASTAs (by BUSCO group)
OUT_DIR="results/codon_alignment"                                 # Output directory for codon alignments
LOG_FILE="${OUT_DIR}/codon_alignment.log"

# === Create output directory and clear previous log ===
mkdir -p "$OUT_DIR"
echo "" > "$LOG_FILE"

echo "Starting codon alignment generation..."
TOTAL=0
SUCCESS=0
SKIPPED=0
FAILED=0

# === Process each AA alignment ===
for AA_FILE in "$AA_DIR"/*.fasta; do
    BASENAME=$(basename "$AA_FILE" .fasta)
    NT_FILE="${NT_DIR}/${BASENAME}/${BASENAME}.fa"
    OUT_FILE="${OUT_DIR}/${BASENAME}.fasta"

    TOTAL=$((TOTAL + 1))
    echo "Processing $BASENAME..." >> "$LOG_FILE"

    if [[ ! -f "$NT_FILE" ]]; then
        echo "Skipping $BASENAME: NT file not found" | tee -a "$LOG_FILE"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # === Extract headers ===
    mapfile -t AA_HEADERS < <(grep '^>' "$AA_FILE" | sed 's/^>//')
    mapfile -t NT_HEADERS < <(grep '^>' "$NT_FILE" | sed 's/^>//')

    if [[ ${#AA_HEADERS[@]} -ne ${#NT_HEADERS[@]} ]]; then
        echo "ERROR: Header count mismatch for $BASENAME" | tee -a "$LOG_FILE"
        FAILED=$((FAILED + 1))
        continue
    fi

    NT_DUPES=$(printf "%s\n" "${NT_HEADERS[@]}" | sort | uniq -d)
    if [[ -n "$NT_DUPES" ]]; then
        echo "ERROR: Duplicate NT headers in $BASENAME:" | tee -a "$LOG_FILE"
        echo "$NT_DUPES" | tee -a "$LOG_FILE"
        FAILED=$((FAILED + 1))
        continue
    fi

    declare -A NT_SEQS
    current_header=""
    while read -r line; do
        if [[ $line == ">"* ]]; then
            current_header="${line#>}"
            NT_SEQS["$current_header"]=""
        else
            NT_SEQS["$current_header"]+="${line// /}"
        fi
    done < "$NT_FILE"

    {
    for HEADER in "${AA_HEADERS[@]}"; do
        if [[ -z "${NT_SEQS[$HEADER]+_}" ]]; then
            echo "ERROR: Header '$HEADER' not in NT file for $BASENAME" >&2
            exit 1
        fi

        NT_SEQ="${NT_SEQS[$HEADER]^^}"  # uppercase

        if [[ "$NT_SEQ" =~ [^ACGT] ]]; then
            echo "WARNING: NT sequence for $HEADER contains non-ACGT characters" >&2
        fi

        LEN=${#NT_SEQ}
        if (( LEN % 3 != 0 )); then
            echo "ERROR: NT sequence length not divisible by 3 for $HEADER" >&2
            exit 1
        fi

        AA_SEQ=$(awk -v h="$HEADER" '
            BEGIN { found=0 }
            $0 ~ "^>" && $0 ~ h { found=1; next }
            $0 ~ "^>" { found=0 }
            found { printf "%s", $0 }
            END { print "" }
        ' "$AA_FILE")

        CODON_ALIGNED=""
        CODON_IDX=0
        for (( i=0; i<${#AA_SEQ}; i++ )); do
            AA="${AA_SEQ:$i:1}"
            if [[ "$AA" == "-" ]]; then
                CODON_ALIGNED+="---"
            else
                CODON="${NT_SEQ:$((CODON_IDX * 3)):3}"
                if [[ -z "$CODON" || ${#CODON} -ne 3 ]]; then
                    echo "ERROR: Incomplete codon for $HEADER at AA pos $i" >&2
                    exit 1
                fi
                CODON_ALIGNED+="$CODON"
                CODON_IDX=$((CODON_IDX + 1))
            fi
        done

        echo ">$HEADER"
        echo "$CODON_ALIGNED" | fold -w 60
    done
    } > "$OUT_FILE" 2>>"$LOG_FILE" && {
        echo "Success: $BASENAME" >> "$LOG_FILE"
        SUCCESS=$((SUCCESS + 1))
    } || {
        echo "Failed to process $BASENAME" | tee -a "$LOG_FILE"
        FAILED=$((FAILED + 1))
    }

    unset NT_SEQS
done

# === Summary ===
echo "Codon alignment generation complete!"
echo "Summary: Total=$TOTAL | Success=$SUCCESS | Skipped=$SKIPPED | Failed=$FAILED"
echo "Log file: $LOG_FILE"
