#!/bin/bash

# Check if the directory path is provided
if [ -z "$1" ]; then
    echo "Please provide the directory path as an argument."
    exit 1
fi

# Directory containing the files
dir_path="$1"

# Check if the directory exists
if [ ! -d "$dir_path" ]; then
    echo "Directory does not exist."
    exit 1
fi

# Move to the directory
cd "$dir_path" || exit

# Counter for the new filenames
counter=0

# Iterate through each file
for file in *; do
    # Check if the file is a regular file
    if [ -f "$file" ]; then
        # Get the creation date of the file
        creation_date=$(stat -c %y "$file" | cut -d ' ' -f1)
        # Rename the file with the counter and the original file extension
        new_name=$(printf "%02d" "$counter")"$(echo "$file" | sed 's/.*\(\.[^\.]*\)$/\1/')"
        # Increment the counter
        ((counter++))
        # Rename the file
        mv "$file" "$new_name"
        echo "Renamed $file to $new_name"
    fi
done

echo "All files have been renamed sequentially."
