#!/bin/bash
# Auto update script - updates system on startup to make sure security updates are applied in shortest amount of time
# Define variables
SERVICE_PATH="/etc/systemd/system/update_script.service"
USERNAME=$(whoami)
LOG_FILE="/var/log/update_script.log"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

# Check if DNF is installed
if ! command -v dnf &> /dev/null; then
    echo "DNF is not installed. Please install it first."
    exit 1
fi

# Backup existing service if it exists
if [ -f "$SERVICE_PATH" ]; then
    echo "Backing up existing service file to $SERVICE_PATH.bak"
    cp "$SERVICE_PATH" "$SERVICE_PATH.bak"
fi

# Create the systemd service
sudo bash -c "cat << 'EOF' > $SERVICE_PATH
[Unit]
Description=Update and Upgrade Script

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'sudo dnf check-update && sudo dnf upgrade -y && sudo dnf autoremove -y >> $LOG_FILE 2>&1'
User=$USERNAME

[Install]
WantedBy=multi-user.target
EOF"

# Enable the service to run at startup
sudo systemctl enable update_script.service

# Inform the user
echo "Systemd service created successfully."
echo "The service will run at startup to update, upgrade, and autoremove packages."
echo "Output will be logged to $LOG_FILE."

