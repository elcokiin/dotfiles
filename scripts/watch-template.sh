#!/bin/zsh

# link with ~/.local/bin/watch-template.sh

# Directory for dotfiles
WATCH_DIR="$PATH_DOTFILES"

# Watch for changes in .template files and ~/.env
inotifywait -m -r -e close_write --format "%w%f" "$WATCH_DIR" ~/.env | while read file; do
    # Check if the changed file is ~/.env
    if [[ "$file" == "$HOME/.env" ]]; then
        echo "Detected changes in ~/.env. Regenerating all templates..."

        # Export new environment variables
        export $(grep -v '^#' ~/.env | xargs)

        # Scan and regenerate all .template files
        find "$WATCH_DIR" -type f -name "*.template" | while read template; do
            output_file="${template%.template}"
            echo "Generating $output_file from $template"
            envsubst < "$template" > "$output_file"
        done
    fi

    # Check if the file has a .template extension
    if [[ "$file" =~ \.template$ ]]; then
        output_file="${file%.template}"
        echo "Generating $output_file from $file"
        envsubst < "$file" > "$output_file"
    fi
done

