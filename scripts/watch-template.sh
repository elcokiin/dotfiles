#!/bin/zsh

# ~/.local/bin/watch-template.sh

# Directory for dotfiles
WATCH_DIR="$PATH_DOTFILES"

# Use inotifywait to watch for changes in the directory and subdirectories
inotifywait -m -r -e close_write --format "%w%f" "$WATCH_DIR" | while read file; do
    # Check if the file has a .template extension
    if [[ "$file" =~ \.template$ ]]; then
        # Generate the output file name without the .template extension
        output_file="${file%.template}"
        echo "Generating $output_file from $file"

        # Run envsubst to substitute environment variables and create the file
        envsubst < "$file" > "$output_file"
    fi
done
