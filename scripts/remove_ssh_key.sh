#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 -u username"
    echo "  -u: Specify the username whose SSH keys you want to manage."
    exit 1
}

# Parse command-line options
while getopts "u:" opt; do
    case $opt in
        u) username=$OPTARG ;;
        *) usage ;;
    esac
done

# Check if username was provided
if [ -z "$username" ]; then
    echo "Username must be provided."
    usage
fi

# Check if user exists
if ! id "$username" &>/dev/null; then
    echo "User $username does not exist."
    exit 1
fi

# Define path for authorized_keys file
USER_HOME=$(getent passwd "$username" | cut -d: -f6)
AUTHORIZED_KEYS="$USER_HOME/.ssh/authorized_keys"

# Check if authorized_keys file exists
if [ ! -f "$AUTHORIZED_KEYS" ]; then
    echo "No authorized_keys file found for user $username."
    exit 1
fi

# Read and display keys with numbers
echo "SSH Keys for user $username:"
IFS=$'\n' read -d '' -r -a key_list < "$AUTHORIZED_KEYS"
if [ ${#key_list[@]} -eq 0 ]; then
    echo "No SSH keys available for removal."
    exit 1
fi

count=1
for key in "${key_list[@]}"; do
    echo "$count) $key"
    ((count++))
done

# Prompt user for which key to remove
read -p "Enter the number of the key to remove (or anything else to exit): " selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#key_list[@]}" ]; then
    echo "Invalid input. Exiting without changes."
    exit 1
fi

# Remove the selected key
unset key_list[$((selection-1))]
printf "%s\n" "${key_list[@]}" > "$AUTHORIZED_KEYS"

echo "Key number $selection removed successfully."

exit 0