#!/bin/bash

# Configuration Variables
NERD_DICTATION_DIR="$HOME/programs/nerd-dictation"
MODEL_DIR="$NERD_DICTATION_DIR/model"
VENV_DIR="$NERD_DICTATION_DIR/nerd-dictation-venv"
TOGGLE_SCRIPT="$NERD_DICTATION_DIR/toggle_dictation.sh"
SHORTCUT_NAME="Toggle Dictation"
SHORTCUT_COMMAND="$TOGGLE_SCRIPT"
SHORTCUT_KEY="<Super>D"

# Update and Install Dependencies
echo "Installing necessary dependencies..."
sudo apt update
sudo apt install -y python3 python3-venv python3-pip ffmpeg xdotool

# Clone Nerd-Dictation Repository
echo "Cloning Nerd-Dictation repository..."
mkdir -p "$NERD_DICTATION_DIR"
git clone https://github.com/ideasman42/nerd-dictation.git "$NERD_DICTATION_DIR"

# Create Virtual Environment
echo "Setting up virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
pip install vosk
deactivate

# Download Vosk Model
echo "Downloading Vosk model..."
wget -O "$NERD_DICTATION_DIR/vosk-model.zip" https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip
unzip "$NERD_DICTATION_DIR/vosk-model.zip" -d "$MODEL_DIR"
rm "$NERD_DICTATION_DIR/vosk-model.zip"

# Create Toggle Script
echo "Creating toggle script..."
cat <<EOL > "$TOGGLE_SCRIPT"
#!/bin/bash

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Check if dictation is running
if pgrep -f "nerd-dictation begin" > /dev/null; then
    echo "Stopping dictation..."
    "$NERD_DICTATION_DIR/nerd-dictation" end
else
    echo "Starting dictation..."
    "$NERD_DICTATION_DIR/nerd-dictation" begin --vosk-model-dir="$MODEL_DIR" &
fi

# Deactivate the virtual environment
deactivate
EOL
chmod +x "$TOGGLE_SCRIPT"

# Create Keyboard Shortcut
echo "Assigning keyboard shortcut..."
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
    "$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings | sed "s/]/, '\/org\/gnome\/settings-daemon\/plugins\/media-keys\/custom-keybindings\/$SHORTCUT_NAME\/']/")"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/"$SHORTCUT_NAME"/name "'$SHORTCUT_NAME'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/"$SHORTCUT_NAME"/command "'$SHORTCUT_COMMAND'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/"$SHORTCUT_NAME"/binding "'$SHORTCUT_KEY'"

echo "Installation complete! Press $SHORTCUT_KEY to toggle dictation."

