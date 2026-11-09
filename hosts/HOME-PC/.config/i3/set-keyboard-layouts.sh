#!/bin/bash

# HOME-PC keyboard layouts. i3 runs this via
# `exec_always ... ~/.config/i3/set-keyboard-layouts.sh`; the file is optional,
# so hosts without an overlay keep the X server default.

# The desktop keyboards are German. Set it globally first, so every keyboard
# starts out German and a device whose name we fail to match does not fall
# back to the X server default.
setxkbmap -layout de

# Corne: German layout (explicit, also matches the global default above)
corne_id=$(xinput list | grep -i "corne" | grep "slave  keyboard" | grep -oP 'id=\K[0-9]+' | head -n1)
if [ -n "$corne_id" ]; then
    setxkbmap -device "$corne_id" -layout de
fi
