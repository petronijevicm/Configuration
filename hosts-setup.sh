#!/bin/bash
#require_sudo
# Script adds StevenBlacks host file into system and caches old one in hosts.bak, it also changes 0.0.0.0 to 127.0.0.1 for security reasons
URL="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"
TEMP_FILE="/tmp/hosts_temp"
HOSTS_FILE="/etc/hosts"
BACKUP_FILE="$HOSTS_FILE.bak.$(date +%Y%m%d%H%M%S)"

# Function to download the hosts file
download_hosts_file() {
    echo "Downloading hosts file from $URL..."
    if curl -s -o "$TEMP_FILE" "$URL"; then
        echo "Download successful."
    else
        echo "Download failed. Exiting."
        exit 1
    fi
}

# Function to modify the hosts file
modify_hosts_file() {
    echo "Modifying hosts file..."
    sed -i 's/0.0.0.0/127.0.0.1/g' "$TEMP_FILE"
}

# Function to backup the original hosts file
backup_hosts_file() {
    echo "Backing up the original hosts file..."
    cp "$HOSTS_FILE" "$BACKUP_FILE"
}

# Function to update the hosts file
update_hosts_file() {
    echo "Updating the hosts file..."
    if cat "$TEMP_FILE" >> "$HOSTS_FILE"; then
        echo "Hosts file updated successfully."
    else
        echo "Failed to update hosts file. Restoring from backup."
        cp "$BACKUP_FILE" "$HOSTS_FILE"
        exit 1
    fi
}

# Function to flush DNS cache and restart NetworkManager
flush_and_restart_network() {
    echo "Flushing DNS cache and restarting NetworkManager..."
    systemctl restart NetworkManager
    echo "NetworkManager restarted."
}

# Clean up temporary file on exit
cleanup() {
    rm -f "$TEMP_FILE"
    echo "Temporary files cleaned up."
}

# Trap to ensure cleanup happens on exit
trap cleanup EXIT

# Main script execution
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo."
    exit 1
fi

backup_hosts_file
download_hosts_file
modify_hosts_file
update_hosts_file
flush_and_restart_network

echo "Host file updated successfully."

