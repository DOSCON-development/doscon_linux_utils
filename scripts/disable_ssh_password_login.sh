#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# File path to the SSHD configuration
SSHD_CONFIG="/etc/ssh/sshd_config"

# Backup the original SSHD configuration file
cp "$SSHD_CONFIG" "$SSHD_CONFIG.backup"

# Disable password authentication in the SSHD config
sed -i '/^PasswordAuthentication/s/^.*$/PasswordAuthentication no/' "$SSHD_CONFIG"

# Check if sed has changed the file, if not add the required line
if ! grep -q "^PasswordAuthentication no$" "$SSHD_CONFIG"; then
    echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
fi

# Restart the SSH service to apply changes
systemctl restart sshd

echo "Password authentication has been disabled."
