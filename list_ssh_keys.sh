#!/bin/bash

# Ensure the script is run with appropriate permissions
if [ "$(id -u)" -ne 0 ]; then
    echo "This script should be run as root to ensure access to all home directories."
    exit 1
fi

# Print header
echo "Username: SSH Key Last 40 Characters"

# Get list of users from /etc/passwd and their home directories
getent passwd | while IFS=: read -r username _ uid gid gecos home shell; do
    # Only process users with a valid login shell (you might want to adjust the list of valid shells according to your environment)
    if [[ "$shell" =~ /bin/bash$|/bin/sh$ ]]; then
        # Check if the .ssh/authorized_keys file exists
        authorized_keys="$home/.ssh/authorized_keys"
        if [ -f "$authorized_keys" ]; then
            # Count the non-empty lines in the file
            key_count=$(grep -cve '^\s*$' "$authorized_keys")
            # Check if there are fewer than 5 non-empty lines
            if [ "$key_count" -ge 5 ]; then
                # Read each non-empty line from authorized_keys file
                grep -v '^\s*$' "$authorized_keys" | while read -r key; do
                    # Extract the last 40 characters of the key
                    last40="${key: -40}"
                    echo "$username: $last40"
                done
            else
                echo "$username: Insufficient SSH keys (<5 keys)"
            fi
        else
            echo "$username: No SSH key found"
        fi
    fi
done
