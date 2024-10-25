#!/usr/bin/bash

# Make colors.lua symbolic link
ln -sf "$HOME/.cache/wal/colors.lua" ./colors.lua

# Make wallpapers symbolic link
ln -sf "/usr/share/wallpapers" ./wallpapers
