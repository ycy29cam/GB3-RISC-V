#!/bin/bash

# Path to source files (adjust if needed)
SOURCE_DIR=.
DEST_DIR1=../processor/programs
DEST_DIR2=../processor/verilog

# Create destination directories if they don't exist

# Move the files to both destinations
cp "$SOURCE_DIR/program.hex" "$DEST_DIR1/"
cp "$SOURCE_DIR/data.hex" "$DEST_DIR1/"

cp "$SOURCE_DIR/program.hex" "$DEST_DIR2/"
cp "$SOURCE_DIR/data.hex" "$DEST_DIR2/"

echo "Files copied to:"
echo " - $DEST_DIR1"
echo " - $DEST_DIR2"