#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Prompt for the new username
read -p "Enter the username for the new user: " username

# Check if the user already exists
if id "$username" &>/dev/null; then
    echo "Error: User '$username' already exists."
    exit 1
fi

# Prompt for and read the public SSH key
read -p "Enter the public SSH key: " ssh_key

# Prompt for the user password and verify it
while true; do
    read -s -p "Enter password: " password
    echo
    read -s -p "Retype password: " password2
    echo
    if [ "$password" = "$password2" ]; then
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done

# Create the user with the provided password (encrypts password using openssl and passes the encrypted password to the useradd function)
useradd -m -p "$(openssl passwd -1 "$password")" -s /bin/bash "$username"

# Create .ssh directory in the user's home directory
home_dir="/home/$username"
ssh_dir="$home_dir/.ssh"
mkdir -p "$ssh_dir"

# Create authorized_keys file and add the public key
echo "$ssh_key" > "$ssh_dir/authorized_keys"

# Set the owner of the .ssh directory and the authorized_keys file
chown -R "$username:$username" "$ssh_dir"
chmod 700 "$ssh_dir"
chmod 600 "$ssh_dir/authorized_keys"

# Ask if the user should have sudo privileges
while true; do
    read -p "Should the user have sudo privileges? (yes/no): " grant_sudo
    if [[ "$grant_sudo" == "yes" ]]; then
        usermod -aG sudo "$username"
        echo "User '$username' has been added to the sudo group."
        break
    elif [[ "$grant_sudo" == "no" ]]; then
        echo "No sudo privileges granted to $username."
        break
    else
        echo "Please answer 'yes' or 'no'."
    fi
done

echo "User '$username' created successfully with SSH access."
