#!/bin/bash
# Script for running benchmarks with a specific configuration file and trace file

# Input arguments
CONFIG_FILE=$1  # Path to the configuration file
TRACE_DIR=$2    # Directory containing trace files
TRACE_FILE=$3   # Name of the trace file (e.g., 3mm_trace.out)
ROB=$4          # ROB size
IPC=$5          # IPC value
LSQ=$6          # LSQ size

# Extract benchmark name
BM="${TRACE_FILE%.*}"  # Removes the file extension from TRACE_FILE (e.g., 3mm_trace)
echo "Setting up directory for benchmark: $BM"
# rm -rf $BM
# mkdir $BM

# Set up a unique summary file for this sweep

# Temporary log for simulation output
SIM_LOG="$BM/simulation_output.log"

# Run the simulator and capture outputs
echo "Running simulation for $BM with ROB=$ROB, IPC=$IPC, LSQ=$LSQ"
./run.sh "$CONFIG_FILE" "$TRACE_DIR" "$TRACE_FILE" 2> "$SIM_LOG"

# Parse simulation results
echo "Parsing results for $BM..."
labdata=$(cat "$SIM_LOG" | python3 lab_parser.py)

# Save parsed results to CSV
echo "$labdata" > "$BM/labdata.csv"

# Remove duplicates in the CSV file
cp -a "$BM/labdata.csv" "$BM/labdata_tmp.csv"
awk '!a[$0]++' "$BM/labdata_tmp.csv" > "$BM/labdata.csv"
rm -rf "$BM/labdata_tmp.csv"

# Extract metrics
execTime=$(echo "$labdata" | tail -1 | cut -d, -f6)
requests=$(echo "$labdata" | tail -1 | cut -d, -f1)
misses=$(echo "$labdata" | grep -c "L1: Was the request a miss?,0,1,boolean")
hits=$(expr "$requests" - "$misses")

echo "${BM}_ROB${ROB}_IPC${IPC}_LSQ${LSQ}_summary.log"
# Save metrics to the uniquely named summary file


# Print metrics to the terminal
echo "Execution time: $execTime" |& tee ${BM}/${BM}_ROB${ROB}_IPC${IPC}_LSQ${LSQ}_summary.log
echo "Total number of requests: $requests" |& tee -a ${BM}/${BM}_ROB${ROB}_IPC${IPC}_LSQ${LSQ}_summary.log
echo "Total number of hits:     $hits" |& tee -a ${BM}/${BM}_ROB${ROB}_IPC${IPC}_LSQ${LSQ}_summary.log
echo "Total number of misses:   $misses" |& tee -a ${BM}/${BM}_ROB${ROB}_IPC${IPC}_LSQ${LSQ}_summary.log
echo "Results saved to $BM/${BM}_ROB${ROB}_IPC${IPC}_LSQ${LSQ}_summary.log"
