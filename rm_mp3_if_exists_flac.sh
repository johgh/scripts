#!/bin/bash

# Define the root directory to start the search
root_directory="/media/MEDIA/Music/Albums/"

# Find all FLAC files and store their directory paths in an array
mapfile -t flac_directories < <(find "$root_directory" -type f -name "*.flac" -exec dirname {} \; | sort -u)

# Initialize an array to store directories with both FLAC and MP3 files
directories_with_both=()

# Iterate through the FLAC directories
for directory in "${flac_directories[@]}"; do
    # Check if the directory contains MP3 files
    if [[ -n $(find "$directory" -type f -name "*.mp3") ]]; then
        directories_with_both+=("$directory")
    fi
done

# Print the directories with both FLAC and MP3 files
if [[ ${#directories_with_both[@]} -gt 0 ]]; then
    echo "Removed MP3 from Directories with both FLAC and MP3 files:"
    printf "%s\n" "${directories_with_both[@]}"
    # Loop through the directories and remove MP3 files in each directory
    for directory in "${directories_with_both[@]}"; do
        rm "$directory"/*.mp3
    done
else
    echo "No directories found with both FLAC and MP3 files."
fi
