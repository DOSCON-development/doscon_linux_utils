#!/bin/bash

# Ensure the script is run with appropriate permissions
if [ "$(id -u)" -ne 0 ]; then
    echo "This script should be run as root to ensure access to all home directories."
    exit 1
fi

# Check if an argument was provided for the number of characters to display
if [ -n "$1" ]; then
    num_chars="$1"
else
    num_chars=0
fi

# Print header
echo "Username: SSH Key Output"

# Get list of users from /etc/passwd and their home directories
getent passwd | while IFS=: read -r username _ uid gid gecos home shell; do
    # Only process users with a valid login shell (you might want to adjust the list of valid shells according to your environment)
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
                        # Decide on the part of the key to display based on input
                        if [ "$num_chars" -gt 0 ]; then
                            # Extract the last $num_chars characters of the key
                            key_output="${key: -$num_chars}"
                        else
                            # Print the entire key
                            key_output="$key"
                        fi
                        echo "$username: $key_output"
                    fi
                done < "$authorized_keys"
            else
                echo "$username: SSH keys file too small (<5 bytes)"
            fi
        else
            echo "$username: No SSH key found"
        fi
    fi
done
