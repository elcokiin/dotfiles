#!/bin/sh

HOME_DIR=/home/elcokiin

DOTFILES_DIR=/home/elcokiin/Code/dotfiles
CONFIG_DIR=/home/elcokiin/Code/dotfiles/config
TARGET_CONFIG_DIR=/home/elcokiin/.config
LOG_FILE=/home/elcokiin/Code/dotfiles/install.log 
SCRIPTS_DIR=/home/elcokiin/Code/dotfiles/scripts
TARGET_SCRIPTS_DIR=/home/elcokiin/.local/bin
ROOT_SCRIPTS_DIR=/usr/local/bin
SERVICES_PATH=/etc/systemd/system

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with administrator permissions (sudo)."
    exit 1
fi

# redirect stdout and stderr to file log
exec > "$LOG_FILE" 2>&1

echo ""
echo "================================================================================================================================"
echo "Start creating symlinks: $(date)"
echo "================================================================================================================================"
echo ""

echo "To see what the script has just done visit the file: '$LOG_FILE'" > /dev/tty

if [ ! -d "$CONFIG_DIR" ]; then
    echo "The directory config doesnt exist in dotfiles. Creating..."
    mkdir -p "$CONFIG_DIR"
fi

######## LINKS TO .CONFIG DIRECTORY ########

for folder in "$CONFIG_DIR"/*; do
    folder_name=$(basename "$folder")

    # check if directory exist ~/.config
    if [ -d "$TARGET_CONFIG_DIR/$folder_name" ]; then
        echo "The directory '$folder_name' alrady exist in $TARGET_CONFIG_DIR."
        
        echo "Making backup for '$folder_name' -> '$folder_name'-backup"
				if [ -d "$TARGET_CONFIG_DIR/$folder_name-backup" ]; then
					echo "Deleting before backup for: '$folder_name'"
					rm -rf "$TARGET_CONFIG_DIR/$folder_name-backup"|| { echo "Error deleting directory: '$folder_name'"; exit 1; }
				fi
        cp -r "$TARGET_CONFIG_DIR/$folder_name" "$TARGET_CONFIG_DIR/${folder_name}-backup" || { echo "Error copy directory '$folder_name'"; exit 1; }
        
        echo "Deleting original directory: '$folder_name'"
        rm -rf "$TARGET_CONFIG_DIR/$folder_name" || { echo "Error deleting directory: '$folder_name'"; exit 1; }
    fi

    echo "Creating symlink for: '$folder_name'..."
    ln -s "$folder" "$TARGET_CONFIG_DIR/$folder_name" || { echo "Error creating symlink for '$folder_name'"; exit 1; }
done

######## ########

######## LINKS FOR SCRIPTS FILES ########

for file in "$SCRIPTS_DIR"/*; do
	file_name=$(basename "$file")

	if [ -e "$TARGET_SCRIPTS_DIR/$file_name" ]; then
		echo "The file '$file_name' alrady exist in '$TARGET_SCRIPTS_DIR'"
		echo "Making backup for '$file_name'-> '$folder_name'.backup"
    cp "$TARGET_SCRIPTS_DIR/$file_name" "$TARGET_SCRIPTS_DIR/${file_name}.backup" || { echo "Error copy '$file_name' for backup"; exit 1; }
    echo "Delating original file '$file_name'..."
    rm -f "$TARGET_SCRIPTS_DIR/$file_name" || { echo "Error removing file '$file_name'"; exit 1; }
	fi
	echo "Creating the symlink for '$file_name'..."
  ln -s "$file" "$TARGET_SCRIPTS_DIR/$file_name" || { echo "Error creating symlink file '$file_name'"; exit 1; }
done

echo "Creating symlinks for battery-monitor daemon"
ln -sf "$DOTFILES_DIR/systemd/battery-monitor.service" "$SERVICES_PATH/battery-monitor.service" || { echo "Error creating symlink for battery-monitor.service"; exit 1; } 
ln -sf "$DOTFILES_DIR/systemd/battery-monitor.timer" "$SERVICES_PATH/battery-monitor.timer" || { echo "Error creating symlink for battery-monitor.timer"; exit 1; }
ln -sf "$DOTFILES_DIR/scripts/battery-monitor.sh" "$ROOT_SCRIPTS_DIR/battery-monitor.sh" || { echo "Error creating symlink for battery-monitor.sh"; exit 1; }

######## ########

######## LINKS TO HOME DIRECTORY ########

FILES=(
  ".env:.env_example"
  ".gitconfig:.gitconfig"
  ".zsh_aliases:.zsh_aliases"
  ".zshrc:.zshrc"
)


# Loop through the list of files
for file in "${FILES[@]}"; do
  # Split the entry into destination file and source file
  DEST_FILE=$(echo "$file" | cut -d':' -f1) # File to be linked in the HOME directory
  SRC_FILE=$(echo "$file" | cut -d':' -f2)  # Corresponding file in the DOTFILES directory

  # Check if the destination file already exists
  if [ -e "$HOME_DIR/$DEST_FILE" ]; then
    echo "Creating backup for $DEST_FILE as $DEST_FILE.backup"
    mv "$HOME_DIR/$DEST_FILE" "$HOME_DIR/$DEST_FILE.backup" # Backup the existing file
  fi

  # Create the symbolic link
  echo "Creating symlink for $DEST_FILE"
  ln -s "$DOTFILES_DIR/$SRC_FILE" "$HOME_DIR/$DEST_FILE" # Link source file to destination
done

######## ########


echo ""
echo "================================================================================================================================"
echo "Finish symlinks creations: $(date)"
echo "================================================================================================================================"
echo ""


