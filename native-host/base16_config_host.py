#!/usr/bin/env python3
"""
Native messaging host for Base16 Everything extension.
Reads config from ~/.config/base16-everything/config.yaml
"""

import json
import os
import re
import struct
import sys
from pathlib import Path

CONFIG_PATH = Path.home() / ".config" / "base16-everything" / "config.yaml"


def parse_yaml_palette(yaml_content):
    """Parse base24 YAML format and extract palette colors."""
    palette = []
    # Base24: base00-base0F (16) + base10-base17 (8) = 24 colors
    base_keys = [
        "base00",
        "base01",
        "base02",
        "base03",
        "base04",
        "base05",
        "base06",
        "base07",
        "base08",
        "base09",
        "base0A",
        "base0B",
        "base0C",
        "base0D",
        "base0E",
        "base0F",
        "base10",
        "base11",
        "base12",
        "base13",
        "base14",
        "base15",
        "base16",
        "base17",
    ]

    for key in base_keys:
        # Match: base00: "#002b36" or base00: "002b36" or base00: 002b36
        pattern = rf'{key}:\s*["\']?#?([0-9a-fA-F]{{6}})["\']?'
        match = re.search(pattern, yaml_content)
        if match:
            palette.append("#" + match.group(1).lower())

    return palette


def parse_config(yaml_content):
    """Parse config.yaml - single theme file in tinted-theming base24 format."""
    palette = parse_yaml_palette(yaml_content)
    if len(palette) == 24:
        return {"palette": palette}
    return {"palette": None, "error": f"Invalid palette - expected 24 colors, got {len(palette)}"}


def read_config():
    """Read and parse the config file."""
    if not CONFIG_PATH.exists():
        return {"error": f"Config file not found: {CONFIG_PATH}"}

    try:
        content = CONFIG_PATH.read_text()
        config = parse_config(content)
        config["path"] = str(CONFIG_PATH)
        config["exists"] = True
        return config
    except Exception as e:
        return {"error": str(e)}


def get_message():
    """Read a message from stdin."""
    raw_length = sys.stdin.buffer.read(4)
    if not raw_length:
        return None
    message_length = struct.unpack("=I", raw_length)[0]
    message = sys.stdin.buffer.read(message_length).decode("utf-8")
    return json.loads(message)


def send_message(message):
    """Send a message to stdout."""
    encoded = json.dumps(message).encode("utf-8")
    sys.stdout.buffer.write(struct.pack("=I", len(encoded)))
    sys.stdout.buffer.write(encoded)
    sys.stdout.buffer.flush()


def main():
    """Main loop - handle messages from extension."""
    while True:
        message = get_message()
        if message is None:
            break

        if message.get("type") == "GET_CONFIG":
            response = read_config()
            send_message(response)
        elif message.get("type") == "PING":
            send_message({"pong": True})
        else:
            send_message({"error": "Unknown message type"})


if __name__ == "__main__":
    main()
