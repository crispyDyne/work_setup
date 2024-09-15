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

# Create repos folder in home directory
mkdir -p ~/repos

# Clone the crispyDyne/ubuntu_home repository
git clone https://github.com/crispyDyne/work_setup.git ~/repos/work_setup

echo "Setup complete!"
