#!/bin/bash

# Check if ImageMagick is installed
if ! command -v convert &>/dev/null; then
    echo "ImageMagick is not installed. Please install it first."
    exit 1
fi

# Check if the directory path argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

directory="$1"

# Check if the provided path is a directory
if [ ! -d "$directory" ]; then
    echo "Error: '$directory' is not a valid directory."
    exit 1
fi

# Loop through .avif and .webp files and convert them to .jpg
for file in "$directory"/*.{avif,webp,png}; do
    if [ -f "$file" ]; then
        filename=$(basename -- "$file")
        extension="${filename##*.}"
        filename="${filename%.*}"
        convert "$file" "$directory/$filename.jpg"
        echo "Converted: $file to $directory/$filename.jpg"
    fi
done

echo "Conversion complete."
