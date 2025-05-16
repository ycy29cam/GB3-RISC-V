#!/bin/bash

# Path to source files (adjust if needed)
SOURCE_DIR=.
DEST_DIR=../processor/programs  # or adjust the path as needed

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Move the files
mv "$SOURCE_DIR/program.hex" "$DEST_DIR/"
mv "$SOURCE_DIR/data.hex" "$DEST_DIR/"

echo "Files moved to $DEST_DIR"