#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 -u username -k \"ssh-rsa AAA...\""
    echo "  -u: Specify the username."
    echo "  -k: Specify the SSH key."
    exit 1
}

# Parse command-line options
while getopts "u:k:" opt; do
    case $opt in
        u) username=$OPTARG ;;
        k) key=$OPTARG ;;
        *) usage ;;
    esac
done

# Check if both username and key were provided
if [ -z "$username" ] || [ -z "$key" ]; then
    echo "Both username and key must be provided."
    usage
fi

# Check if user exists
if ! id "$username" &>/dev/null; then
    echo "User $username does not exist."
    exit 1
fi

# Define path for authorized_keys file
USER_HOME=$(getent passwd "$username" | cut -d: -f6)
SSH_DIR="$USER_HOME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# Ensure SSH directory exists with correct permissions
if [ ! -d "$SSH_DIR" ]; then
    mkdir "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    chown "$username":"$(id -gn "$username")" "$SSH_DIR"
fi

# Ensure authorized_keys file exists with correct permissions
if [ ! -f "$AUTHORIZED_KEYS" ]; then
    touch "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
    chown "$username":"$(id -gn "$username")" "$AUTHORIZED_KEYS"
fi

# Append key to authorized_keys file
echo "$key" >> "$AUTHORIZED_KEYS"
echo "Key added successfully to $AUTHORIZED_KEYS"

exit 0