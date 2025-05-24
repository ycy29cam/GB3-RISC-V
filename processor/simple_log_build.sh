#!/bin/bash

LOGFILE="build_log.txt"
echo "Build started: $(date)" > "$LOGFILE"

# Run yosys
echo -e "\n===== YOSYS OUTPUT =====\n" >> "$LOGFILE"
yosys -q /gb3-resources/processor/yscripts/sail.ys >> "$LOGFILE" 2>&1

# Run nextpnr
echo -e "\n===== NEXTPNR OUTPUT =====\n" >> "$LOGFILE"
nextpnr-ice40 --up5k --package uwg30 --json sail.json --pcf pcf/sail.pcf --asc sail.asc >> "$LOGFILE" 2>&1

# Optionally run icetime
echo -e "\n===== ICETIME TIMING ANALYSIS =====\n" >> "$LOGFILE"
icetime -p pcf/sail.pcf -P uwg30 -d up5k -t sail.asc >> "$LOGFILE" 2>&1

echo "Build completed: $(date)" >> "$LOGFILE"

