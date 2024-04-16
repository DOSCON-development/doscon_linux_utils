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
        # Check if the .ssh/authorized_keys file exists and is not empty
        authorized_keys="$home/.ssh/authorized_keys"
        if [ -f "$authorized_keys" ] && [ -s "$authorized_keys" ]; then
            # Read each line from authorized_keys file
            while read -r key; do
                # Check if the line is empty
                if [ -n "$key" ]; then
                    # Extract the last 40 characters of the key
                    last="${key: -40}"
                    echo "$username: $last"
                fi
            done < "$authorized_keys"
        else
            echo "$username: No SSH key found"
        fi
    fi
done
