#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_NAME="com.base16.everything"

echo "=== Base16 Everything Native Host Installer ==="
echo ""

FIREFOX_MODE=false
if [ "$1" = "--firefox" ]; then
    FIREFOX_MODE=true
elif [ -z "$1" ]; then
    echo "Usage: $0 <extension-id>   (Chrome/Chromium)"
    echo "       $0 --firefox        (Firefox)"
    echo ""
    echo "For Chrome/Chromium, find your extension ID:"
    echo "1. Open chrome://extensions"
    echo "2. Find 'Base16 Everything'"
    echo "3. Copy the ID (looks like: mlmhenlobfodphglalpgjpinfidhcbio)"
    exit 1
fi

# Make the host script executable
chmod +x "$SCRIPT_DIR/base16_config_host.py"

if [ "$FIREFOX_MODE" = true ]; then
    # Firefox uses allowed_extensions with the add-on ID
    MANIFEST_CONTENT=$(
        cat <<EOF
{
  "name": "$HOST_NAME",
  "description": "Native messaging host for Base16 Everything",
  "path": "$SCRIPT_DIR/base16_config_host.py",
  "type": "stdio",
  "allowed_extensions": [
    "{a05fa7af-a38d-4616-aadb-5acab1f22ee3}"
  ]
}
EOF
    )

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        MANIFEST_DIR="$HOME/.mozilla/native-messaging-hosts"
        mkdir -p "$MANIFEST_DIR"
        echo "$MANIFEST_CONTENT" >"$MANIFEST_DIR/$HOST_NAME.json"
        echo "Installed manifest to:"
        echo "  - $MANIFEST_DIR/$HOST_NAME.json"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        MANIFEST_DIR="$HOME/Library/Application Support/Mozilla/NativeMessagingHosts"
        mkdir -p "$MANIFEST_DIR"
        echo "$MANIFEST_CONTENT" >"$MANIFEST_DIR/$HOST_NAME.json"
        echo "Installed manifest to:"
        echo "  - $MANIFEST_DIR/$HOST_NAME.json"
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
else
    EXTENSION_ID="$1"

    # Chrome/Chromium uses allowed_origins with the per-install extension UUID
    MANIFEST_CONTENT=$(
        cat <<EOF
{
  "name": "$HOST_NAME",
  "description": "Native messaging host for Base16 Everything",
  "path": "$SCRIPT_DIR/base16_config_host.py",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$EXTENSION_ID/"
  ]
}
EOF
    )

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        CHROME_MANIFEST_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
        CHROMIUM_MANIFEST_DIR="$HOME/.config/chromium/NativeMessagingHosts"

        mkdir -p "$CHROME_MANIFEST_DIR" "$CHROMIUM_MANIFEST_DIR"
        echo "$MANIFEST_CONTENT" >"$CHROME_MANIFEST_DIR/$HOST_NAME.json"
        echo "$MANIFEST_CONTENT" >"$CHROMIUM_MANIFEST_DIR/$HOST_NAME.json"

        echo "Installed manifest to:"
        echo "  - $CHROME_MANIFEST_DIR/$HOST_NAME.json"
        echo "  - $CHROMIUM_MANIFEST_DIR/$HOST_NAME.json"

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        MANIFEST_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
        mkdir -p "$MANIFEST_DIR"
        echo "$MANIFEST_CONTENT" >"$MANIFEST_DIR/$HOST_NAME.json"

        echo "Installed manifest to:"
        echo "  - $MANIFEST_DIR/$HOST_NAME.json"

    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
fi

# Create example config if it doesn't exist
CONFIG_DIR="$HOME/.config/base16-everything"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$CONFIG_DIR"
    cat >"$CONFIG_FILE" <<'EOF'
# Base24 Everything Configuration
# Same format as tinted-theming base24 schemes.
# This overrides extension settings when present.

system: "base24"
name: "Gruvbox Light Hard"
author: "Dawid Kurek (dawikur@gmail.com)"
variant: "light"

palette:
  # base00-base07: backgrounds to foregrounds
  base00: "#f9f5d7"
  base01: "#ebdbb2"
  base02: "#d5c4a1"
  base03: "#bdae93"
  base04: "#665c54"
  base05: "#504945"
  base06: "#3c3836"
  base07: "#282828"
  # base08-base0F: accent colors
  base08: "#9d0006"
  base09: "#af3a03"
  base0A: "#b57614"
  base0B: "#79740e"
  base0C: "#427b58"
  base0D: "#076678"
  base0E: "#8f3f71"
  base0F: "#d65d0e"
  # base10-base17: extended (lighter bg + bright accents)
  base10: "#f2e5bc"
  base11: "#ebdbb2"
  base12: "#cc241d"
  base13: "#d65d0e"
  base14: "#d79921"
  base15: "#98971a"
  base16: "#689d6a"
  base17: "#458588"
EOF
    echo ""
    echo "Created example config at: $CONFIG_FILE"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Next steps:"
if [ "$FIREFOX_MODE" = true ]; then
    echo "1. Restart Firefox"
else
    echo "1. Restart Chrome/Chromium"
fi
echo "2. Edit $CONFIG_FILE to customize your themes"
echo "3. The extension will automatically use your config"
echo ""
