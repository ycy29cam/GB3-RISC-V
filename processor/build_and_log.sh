#!/bin/bash

TOP_MODULE="top"
DEVICE="up5k"
SEEDS=(1 2 3 4 5)
OUTPUT_CSV="resource_usage.csv"

# Clean up
rm -f toplevel.json toplevel.asc $OUTPUT_CSV
echo "Seed,LUTs,DFFs,IOs" > $OUTPUT_CSV

# Synthesis
echo "Running Yosys synthesis..."
yosys -p "read_verilog toplevel.v ./verilog/*.v; hierarchy -top $TOP_MODULE; proc; flatten; opt; synth_ice40 -abc9 -top $TOP_MODULE" -o toplevel.json

# Iterate over seeds
for SEED in "${SEEDS[@]}"; do
  echo "Running nextpnr with seed $SEED..."

  ASC_FILE="toplevel_seed${SEED}.asc"
  nextpnr-ice40 --$DEVICE --json toplevel.json --asc $ASC_FILE --seed $SEED > /dev/null

  # Parse resource usage
  STATS=$(icebox_stat $ASC_FILE)
  LUTS=$(echo "$STATS" | grep LUTs | awk '{print $2}')
  DFFS=$(echo "$STATS" | grep DFFs | awk '{print $2}')
  IOS=$(echo "$STATS" | grep IOs | awk '{print $2}')

  echo "$SEED,$LUTS,$DFFS,$IOS" >> $OUTPUT_CSV
done

echo "Done. See $OUTPUT_CSV for results."

