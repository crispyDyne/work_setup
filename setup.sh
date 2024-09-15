#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y
rm google-chrome-stable_current_amd64.deb

# Install VS Code
sudo apt install software-properties-common apt-transport-https wget -y
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update
sudo apt install code -y

# Install Git
sudo apt install git -y

# Set Git global user config
git config --global user.name "Chris Patton"
git config --global user.email "cd.patton@gmail.com"

# Create repos folder in the current user's home directory
mkdir -p "$HOME/repos"

# Clone the crispyDyne/ubuntu_home repository into the repos folder
git clone https://github.com/crispyDyne/work_setup.git "$HOME/repos/work_setup"

# Copy VS Code settings from the repository to the local machine
cp "$HOME/repos/work_setup/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

# Install desired VS Code extensions
# sudo -u "$SUDO_USER" code --install-extension GitHub.copilot # specificly do not run as sudo. Do I need to?
code --install-extension GitHub.copilot
code --install-extension eamodio.gitlens
code --install-extension streetsidesoftware.code-spell-checker

echo "Setup complete!"
