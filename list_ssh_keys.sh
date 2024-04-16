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
    # Only process users with a valid login shell
    if [[ "$shell" =~ /bin/bash$|/bin/sh$ ]]; then
        # Check if the .ssh/authorized_keys file exists
        authorized_keys="$home/.ssh/authorized_keys"
        if [ -f "$authorized_keys" ]; then
            # Check the size of the file
            file_size=$(stat -c %s "$authorized_keys")
            if [ "$file_size" -ge 5 ]; then
                # Read each line from authorized_keys file
                while read -r key; do
                    # Check if the line is empty
                    if [ -n "$key" ]; then
                        # Extract the last 40 characters of the key
                        last40="${key: -40}"
                        echo "$username: $last40"
                    fi
                done < "$authorized_keys"
            else
                echo "$username: SSH keys file too small (<5 bytes)"
            fi
        else
            echo "$username: No SSH file found"
        fi
    fi
done
