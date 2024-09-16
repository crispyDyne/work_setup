#!/bin/bash

# may need to make the file executable chmod +x setup.sh

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y
rm google-chrome-stable_current_amd64.deb

# Install VS Code
# sudo apt install software-properties-common apt-transport-https wget -y
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update
sudo apt install code -y

# Install Git
sudo apt install git -y

# Set Git global user config for the non-root user
git config --global user.name "Chris Patton"
git config --global user.email "cd.patton@gmail.com"

# Clone the crispyDyne/work_setup repository into the repos folder
git clone https://github.com/crispyDyne/work_setup.git "$HOME/repos/work_setup"

# Copy VS Code settings from the repository to the local machine
cp "$HOME/repos/work_setup/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

# Install VS Code extensions as the regular user
for ext in GitHub.copilot eamodio.gitlens streetsidesoftware.code-spell-checker; do
  code --install-extension "$ext"
done

echo "Setup complete!"
