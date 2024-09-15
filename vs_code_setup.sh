#!/bin/bash

# List of VS Code extensions to install
extensions=(
    eamodio.gitlens
    github.copilot
    streetsidesoftware.code-spell-checker
)

# Install each extension
for extension in "${extensions[@]}"
do
    code --install-extension $extension
done

echo "Extensions installed!"
