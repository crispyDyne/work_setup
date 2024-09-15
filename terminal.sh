#!/bin/bash

# Step 1: Install Starship
echo "Installing Starship..."
wget https://starship.rs/install.sh -O /tmp/starship_install.sh
chmod +x /tmp/starship_install.sh
sudo -u "$SUDO_USER" sh /tmp/starship_install.sh -y

# Step 2: Add Starship initialization to ~/.bashrc if it's not already there
BASHRC_FILE="$HOME/.bashrc"
INIT_LINE='eval "$(starship init bash)"'

if grep -Fxq "$INIT_LINE" "$BASHRC_FILE"; then
    echo "Starship initialization already exists in $BASHRC_FILE"
else
    echo "Adding Starship initialization to $BASHRC_FILE..."
    echo "$INIT_LINE" >> "$BASHRC_FILE"
fi

# Step 3: Create the ~/.config directory if it doesn't exist
CONFIG_DIR="$HOME/.config"
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Creating ~/.config directory..."
    mkdir -p "$CONFIG_DIR"
fi

# Step 4: Set the "pure" preset and output it to ~/.config/starship.toml
echo "Setting the Starship 'pure' preset..."
sudo -u "$SUDO_USER" starship preset pure-preset -o "$CONFIG_DIR/starship.toml"

echo "Starship setup complete! Please restart your terminal or run 'source ~/.bashrc' to apply the changes."
