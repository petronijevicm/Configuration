#!/bin/bash

# Function to remove swap files
remove_swap() {
    # Check for active swap files
    if swapon --show=NAME | grep -q .; then
        echo "Disabling and removing swap files..."
        sudo swapoff -a  # Disable all swap
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to disable swap."
            exit 1
        fi
        
        # Remove swap files (assuming they are in /swapfile or /etc/fstab)
        # You may need to adjust this based on your system configuration
        if [[ -f /swapfile ]]; then
            sudo rm /swapfile
            echo "Removed /swapfile."
        fi
        
        # Check for swap entries in /etc/fstab and remove them
        if grep -q '/swapfile' /etc/fstab; then
            sudo sed -i '/\/swapfile/d' /etc/fstab
            echo "Removed swap entry from /etc/fstab."
        fi
    else
        echo "No active swap files found."
    fi
}

# Remove swap if it exists
remove_swap

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
