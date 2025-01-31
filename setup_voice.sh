#!/bin/bash

# =====================
#  CONFIGURATION
# =====================
NERD_DICTATION_DIR="$HOME/programs/nerd-dictation"
MODEL_DIR="$NERD_DICTATION_DIR/model"
VENV_DIR="$NERD_DICTATION_DIR/nerd-dictation-venv"
TOGGLE_SCRIPT="$NERD_DICTATION_DIR/toggle_dictation.sh"

# Shortcut details
SHORTCUT_ID="toggle-dictation"
BINDING_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/$SHORTCUT_ID/"
SHORTCUT_NAME="Toggle Dictation"
SHORTCUT_COMMAND="$TOGGLE_SCRIPT"
SHORTCUT_KEY="<Super>Z"

# =====================
#  DETECT AUDIO SYSTEM
# =====================
echo "Checking audio system..."

# Get the server name (PulseAudio or PipeWire)
AUDIO_SERVER=$(pactl info | grep 'Server Name' | awk '{print $3}')

if [[ "$AUDIO_SERVER" == "PulseAudio" ]]; then
    echo "Detected PulseAudio. Installing pulseaudio-utils..."
    sudo apt install -y pulseaudio-utils
elif [[ "$AUDIO_SERVER" == "PipeWire" ]]; then
    echo "Detected PipeWire with PulseAudio compatibility. Installing pipewire-pulse..."
    sudo apt install -y pipewire-pulse
else
    echo "Warning: Could not detect a supported audio system (PulseAudio or PipeWire)."
    echo "Nerd-Dictation may not work without parec. Please check your audio setup."
fi

# Verify that parec is installed
if ! command -v parec &> /dev/null; then
    echo "Error: parec is still missing. Please install pulseaudio-utils or pipewire-pulse manually."
    exit 1
fi

# =====================
#  INSTALL DEPENDENCIES
# =====================
echo "Installing necessary dependencies..."
sudo apt update
sudo apt install -y python3 python3-venv python3-pip ffmpeg xdotool wget unzip

# =====================
#  CLONE NERD-DICTATION
# =====================
echo "Cloning Nerd-Dictation repository..."
mkdir -p "$NERD_DICTATION_DIR"
git clone https://github.com/ideasman42/nerd-dictation.git "$NERD_DICTATION_DIR"

# =====================
#  VIRTUAL ENV SETUP
# =====================
echo "Setting up virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
pip install vosk
deactivate

# =====================
#  DOWNLOAD VOSK MODEL
# =====================
echo "Downloading Vosk model..."
wget -O "$NERD_DICTATION_DIR/vosk-model.zip" \
  https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip
mkdir -p "$MODEL_DIR"
unzip "$NERD_DICTATION_DIR/vosk-model.zip" -d "$MODEL_DIR"
rm "$NERD_DICTATION_DIR/vosk-model.zip"

# =====================
#  CREATE TOGGLE SCRIPT
# =====================
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
    "$NERD_DICTATION_DIR/nerd-dictation" begin --vosk-model-dir "$MODEL_DIR/vosk-model-small-en-us-0.15" &
fi

# Deactivate the virtual environment
deactivate
EOL
chmod +x "$TOGGLE_SCRIPT"

# =====================
#  CREATE KEYBINDING
# =====================
echo "Assigning keyboard shortcut..."

# Get existing keybindings
existing="$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)"
existing="${existing#@as }"

# Append new shortcut if not already present
if [[ "$existing" == "[]" ]]; then
    new="['$BINDING_PATH']"
elif [[ "$existing" == *"$BINDING_PATH"* ]]; then
    new="$existing"
else
    new="${existing%]*}, '$BINDING_PATH']"
fi

# Set the updated keybinding list
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "@as $new"

# Write keybinding details
dconf write "${BINDING_PATH}name" "'$SHORTCUT_NAME'"
dconf write "${BINDING_PATH}command" "'$SHORTCUT_COMMAND'"
dconf write "${BINDING_PATH}binding" "'$SHORTCUT_KEY'"

echo "Installation complete! Press $SHORTCUT_KEY to toggle dictation."
