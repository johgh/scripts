#!/bin/bash
IFS=$'\n'       # make newlines the only separator

for FILE in $(find . -name "*.zip" -o -name "*.rar")
do
    BASENAME=$(basename "$FILE")
    DIRNAME=$(dirname "$FILE")

    if [[ $BASENAME == *.zip ]]; then
        NEW_EXT=".cbz"
    elif [[ $BASENAME == *.rar ]]; then
        NEW_EXT=".cbr"
    else
        # Handle other file types if necessary
        continue
    fi

    BASENAME=$(basename "$BASENAME" .zip)
    BASENAME=$(basename "$BASENAME" .rar)

    mv "$FILE" "$DIRNAME/$BASENAME$NEW_EXT"
done

