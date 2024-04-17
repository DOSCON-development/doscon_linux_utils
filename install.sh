#!/bin/bash

# Define the repository URL and the directory containing the scripts
REPO_URL="https://github.com/username/repository.git"
SCRIPTS_DIR="scripts"
TARGET_DIR="/usr/local/sbin"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Clone the repository
cd /tmp
git clone "$REPO_URL" repository

# Check if the scripts directory exists
if [ ! -d "repository/$SCRIPTS_DIR" ]; then
    echo "No scripts directory found. Exiting installation."
    rm -rf /tmp/repository
    exit 1
fi

# Install each script in the scripts directory
for script in repository/$SCRIPTS_DIR/*; do
    script_name=$(basename "$script")
    echo "Installing $script_name..."
    mv "$script" "$TARGET_DIR/$script_name"
    chmod +x "$TARGET_DIR/$script_name"
done

# Clean up
rm -rf /tmp/repository

# Confirm completion
echo "Installation completed successfully."
echo "You can run the scripts from $TARGET_DIR"
