#!/bin/bash

# This laptop (tptimo) types on a US layout. Set it globally first, so every
# keyboard starts out English and a device whose name we fail to match does not
# fall back to the X server default.
setxkbmap -layout us -option compose:rctrl

# Corne: German layout, RAlt stays as AltGr (no compose remap)
corne_id=$(xinput list | grep -i "corne" | grep "slave  keyboard" | grep -oP 'id=\K[0-9]+' | head -n1)
if [ -n "$corne_id" ]; then
    setxkbmap -device "$corne_id" -layout de
fi
