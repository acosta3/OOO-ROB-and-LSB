#!/bin/bash
# Script to run sweeping experiments for multiple benchmarks

# Paths
BASE_CONFIG_FILE="tools/x86_trace_generator/LAB3_Configurations/project_config.xml"  # Original config file
TRACE_DIR="tools/x86_trace_generator/LAB3_BMs"  # Directory containing trace files
COMPILE_RUN_SCRIPT="./compile_and_run.sh"  # Path to compile and run script
TEMP_TRACE="trace_C0.trc.shared"  # Temporary trace file name recognized by the simulation



# Parameters for sweeping
ROB_SIZES=(8 16 32)
IPC_VALUES=(1 2 4 8)
LSQ_SIZES=(1 2 4 8 16 32)

# Default values
DEFAULT_ROB=32
DEFAULT_IPC=4
DEFAULT_LSQ=8

update_config() {
    local rob_size=$1
    local ipc=$2
    local lsb_size=$3

    local temp_config=$(mktemp)  # Create a temporary file
    cp "$BASE_CONFIG_FILE" "$temp_config"

    # Use sed to modify the temporary file
    sed -i -e "s/robSize=\"[0-9]*\"/robSize=\"$rob_size\"/" \
           -e "s/ipc=\"[0-9]*\"/ipc=\"$ipc\"/" \
           -e "s/lsbSize=\"[0-9]*\"/lsbSize=\"$lsb_size\"/" \
           "$temp_config"

    echo "$temp_config"  # Return the path of the modified file
}

# Run sweeping experiments for each benchmark
for trace_file in "$TRACE_DIR"/*.out; do
    trace_name=$(basename "$trace_file")
    echo "Processing trace file: $trace_name"

    # Create a symlink (or copy) for the required trace name
    ln -sf "$trace_file" "$(dirname "$trace_file")/$TEMP_TRACE" # Symlink to the expected trace name

    # Sweep ROB Size
    for rob_size in "${ROB_SIZES[@]}"; do
        ipc=$DEFAULT_IPC
        lsb_size=$DEFAULT_LSQ
        config=$(update_config "$rob_size" "$ipc" "$lsb_size")
        echo "Sweeping ROB Size: ROB=$rob_size, IPC=$ipc, LSQ=$lsb_size"
        $COMPILE_RUN_SCRIPT "$config" "$TRACE_DIR" "$trace_name" "$rob_size" "$ipc" "$lsb_size"
        rm -f "$config"
    done

    # Sweep IPC
    for ipc in "${IPC_VALUES[@]}"; do
        rob_size=$DEFAULT_ROB
        lsb_size=$DEFAULT_LSQ
        config=$(update_config "$rob_size" "$ipc" "$lsb_size")
        echo "Sweeping IPC: ROB=$rob_size, IPC=$ipc, LSQ=$lsb_size"
        $COMPILE_RUN_SCRIPT "$config" "$TRACE_DIR" "$trace_name" "$rob_size" "$ipc" "$lsb_size" > /dev/null 2>&1 
        rm -f "$config"
    done

    # Sweep LSQ Size
    for lsb_size in "${LSQ_SIZES[@]}"; do
        rob_size=$DEFAULT_ROB
        ipc=$DEFAULT_IPC
        config=$(update_config "$rob_size" "$ipc" "$lsb_size")
        echo "Sweeping LSQ Size: ROB=$rob_size, IPC=$ipc, LSQ=$lsb_size"
        $COMPILE_RUN_SCRIPT "$config" "$TRACE_DIR" "$trace_name" "$rob_size" "$ipc" "$lsb_size" > /dev/null 2>&1 
        rm -f "$config" 
    done

    # Clean up the symlink (or temporary file)
    rm -f "$(dirname "$trace_file")/$TEMP_TRACE"

    echo "Sweeping completed for trace file: $trace_name"
done

echo "All sweeping experiments completed."