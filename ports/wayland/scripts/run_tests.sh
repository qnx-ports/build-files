#!/bin/bash

# Loop through all files in the current directory
for file in test-wayland*; do
    # Check if the file exists and is executable
    if [[ -f "$file" && -x "$file" ]]; then
        echo "Executing: $file"
        ./"$file"
        echo "Finished: $file"
        echo "-----------------------"
    else
        echo "Skipping: $file (not an executable or not a file)"
    fi
done
