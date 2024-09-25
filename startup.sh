#!/bin/bash

# Create a temporary directory in RAM
TEMP_DIR=$(mktemp -d -t ci-XXXXXXXXXX)
if [[ ! -d "$TEMP_DIR" ]]; then
    echo "Error: Failed to create temporary directory."
    exit 1
fi

# Clone the GitHub repository into the temporary directory
git clone --depth 1 https://github.com/petronijevicm/Configuration.git "$TEMP_DIR"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to clone repository."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Change to the directory containing the .sh files
cd "$TEMP_DIR/Configuration" || { echo "Error: Failed to change directory."; rm -rf "$TEMP_DIR"; exit 1; }

# Function to execute scripts and handle errors
execute_script() {
    local script="$1"
    echo "Running $script..."
    
    # Check the second line for #require_sudo
    if sed -n '2p' "$script" | grep -q "#require_sudo"; then
        # Run with sudo
        sudo bash "$script"
    else
        # Run without sudo
        bash "$script"
    fi

    if [[ $? -ne 0 ]]; then
        echo "Error: $script failed to execute."
    fi
}

# Find and execute each .sh file, skipping this script
for script in *.sh; do
    if [[ -f "$script" && "$script" != "startup.sh" ]]; then
        execute_script "$script"
    fi
done

# Clean up: remove the temporary directory
rm -rf "$TEMP_DIR"

