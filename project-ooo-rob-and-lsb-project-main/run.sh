#!/bin/bash

# Ensure the script stops on errors
#set -e

# Input Arguments
CONFIG_FILE=$1  # Path to the configuration XML file
TRACE_DIR=$2    # Path to the directory containing trace files
TRACE_FILE=$3   # Name of the trace file to use

# Step 1: Configure the project using waf
./waf configure

# Step 2: Copy the specified trace file into the traces directory and rename it to "trace_C0.trc.shared"
#cp "$TRACE_DIR/$TRACE_FILE" "$TRACE_DIR/trace_C0.trc.shared"

# Step 3: Run the simulator using the configuration file and the traces directory
./waf --run "scratch/MultiCoreSimulator --CfgFile=$CONFIG_FILE --BMsPath=$TRACE_DIR --LogFileGenEnable=0"
