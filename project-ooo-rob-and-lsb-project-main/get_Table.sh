#!/bin/bash

# Base directory containing all benchmark trace folders
BENCHMARKS_DIR="."  # Adjust this if needed

# Parameter values in precise order
ROB_SIZES=(4 8 16 32)
IPC_VALUES=(1 2 4 8)
LSQ_SIZES=(1 2 4 8 16 32)

# Function to append unique lines to the output files
append_unique() {
    local file="$1"
    local line="$2"

    # Check if the line already exists in the file
    if ! grep -Fxq "$line" "$file"; then
        echo "$line" >> "$file"
    fi
}

# Loop through each *_trace folder
for BM_DIR in "$BENCHMARKS_DIR"/*_trace/; do
    # Extract the benchmark name from the folder name
    BM_NAME=$(basename "$BM_DIR")  # Full folder name including "_trace"
    echo "Processing benchmark: $BM_NAME"

    # Output file names
    OUTPUT_ROB="${BM_NAME}_ROB_table.csv"
    OUTPUT_IPC="${BM_NAME}_IPC_table.csv"
    OUTPUT_LSQ="${BM_NAME}_LSQ_table.csv"

    # Overwrite output files with headers
    echo "Benchmark,ROB,Execution Time,LSB Hits" > "$OUTPUT_ROB"
    echo "Benchmark,IPC,Execution Time,LSB Hits" > "$OUTPUT_IPC"
    echo "Benchmark,LSQ,Execution Time,LSB Hits" > "$OUTPUT_LSQ"

    # Sweep ROB sizes
    for rob_size in "${ROB_SIZES[@]}"; do
        ipc=4  # Default IPC for ROB sweep
        lsq_size=8  # Default LSQ for ROB sweep
        SUMMARY_LOG="${BM_DIR}${BM_NAME}_ROB${rob_size}_IPC${ipc}_LSQ${lsq_size}_summary.log"
        if [ -f "$SUMMARY_LOG" ]; then
            EXEC_TIME=$(grep "Execution time:" "$SUMMARY_LOG" | awk -F': ' '{print $2}' | head -n 1 | tr -d '[:space:]')
            LSB_HITS=$(grep "Number of LSB Hits:" "$SUMMARY_LOG" | awk -F': ' '{print $2}' | head -n 1 | tr -d '[:space:]')
            LINE="$BM_NAME,$rob_size,$EXEC_TIME,$LSB_HITS"
            append_unique "$OUTPUT_ROB" "$LINE"
        else
            echo "File not found: $SUMMARY_LOG"
        fi
    done

    # Sweep IPC values
    for ipc in "${IPC_VALUES[@]}"; do
        rob_size=32  # Default ROB for IPC sweep
        lsq_size=8  # Default LSQ for IPC sweep
        SUMMARY_LOG="${BM_DIR}${BM_NAME}_ROB${rob_size}_IPC${ipc}_LSQ${lsq_size}_summary.log"
        if [ -f "$SUMMARY_LOG" ]; then
            EXEC_TIME=$(grep "Execution time:" "$SUMMARY_LOG" | awk -F': ' '{print $2}' | head -n 1 | tr -d '[:space:]')
            LSB_HITS=$(grep "Number of LSB Hits:" "$SUMMARY_LOG" | awk -F': ' '{print $2}' | head -n 1 | tr -d '[:space:]')
            LINE="$BM_NAME,$ipc,$EXEC_TIME,$LSB_HITS"
            append_unique "$OUTPUT_IPC" "$LINE"
        else
            echo "File not found: $SUMMARY_LOG"
        fi
    done

    # Sweep LSQ sizes
    for lsq_size in "${LSQ_SIZES[@]}"; do
        rob_size=32  # Default ROB for LSQ sweep
        ipc=4  # Default IPC for LSQ sweep
        SUMMARY_LOG="${BM_DIR}${BM_NAME}_ROB${rob_size}_IPC${ipc}_LSQ${lsq_size}_summary.log"
        if [ -f "$SUMMARY_LOG" ]; then
            EXEC_TIME=$(grep "Execution time:" "$SUMMARY_LOG" | awk -F': ' '{print $2}' | head -n 1 | tr -d '[:space:]')
            LSB_HITS=$(grep "Number of LSB Hits:" "$SUMMARY_LOG" | awk -F': ' '{print $2}' | head -n 1 | tr -d '[:space:]')
            LINE="$BM_NAME,$lsq_size,$EXEC_TIME,$LSB_HITS"
            append_unique "$OUTPUT_LSQ" "$LINE"
        else
            echo "File not found: $SUMMARY_LOG"
        fi
    done

    echo "Results for $BM_NAME saved to ${OUTPUT_ROB}, ${OUTPUT_IPC}, and ${OUTPUT_LSQ}."
done

