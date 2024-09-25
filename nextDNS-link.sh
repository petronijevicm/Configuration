#!/bin/bash
#require_sudo
# This Part of the script calls NextDNS server to update Linked-ip whenever network(VPN) reconnects
DISPATCHER_SCRIPT="/etc/NetworkManager/dispatcher.d/99-nextdns-link"

sudo bash -c "cat > $DISPATCHER_SCRIPT" << 'EOF'
#!/bin/bash

# Check if the connection is up
if [ "$2" = "up" ]; then
    sleep 2  # Wait for 5 seconds
    curl -s https://link-ip.nextdns.io/[put your config here] >> /var/log/my-network-command.log 2>&1
fi
EOF

sudo chmod u+x "$DISPATCHER_SCRIPT"

# Create the log file and set permissions
sudo touch /var/log/my-network-command.log
sudo chmod 644 /var/log/my-network-command.log

echo "NetworkManager NextDNS script has been set up successfully."

