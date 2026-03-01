#!/bin/sh

# Remove unused applications
# Remember to also delete the Hyprland bindings for the removed apps, or run the stow-hypr.sh script.

# Add the exact package names you want to delete here, separated by spaces
APPS_TO_REMOVE="signal-desktop 1password-beta 1password-cli typora"

echo "Uninstalling the following apps: $APPS_TO_REMOVE"
yay -Rns $APPS_TO_REMOVE

echo "Cleaning up leftover configuration files..."
# The -rf flags tell the system to force delete the folders and their contents without asking for confirmation
rm -rf ~/.config/Signal
rm -rf ~/.config/Typora
rm -rf ~/.config/1Password
rm -rf ~/.config/1password # Added lowercase just in case 1Password saved anything here too!

echo "Done! Don't forget to clean up your config files (bindings)."
