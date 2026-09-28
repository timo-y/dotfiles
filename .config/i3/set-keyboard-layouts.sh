#!/bin/bash

# Laptop's built-in keyboard: US layout + RAlt as Compose
laptop_id=$(xinput list --id-only "AT Translated Set 2 keyboard")
if [ -n "$laptop_id" ]; then
    setxkbmap -device "$laptop_id" -layout us -option compose:rctrl
fi

# Corne: German layout, RAlt stays as AltGr (no compose remap)
corne_id=$(xinput list | grep "Timos Corne Keyboard" | grep "slave  keyboard" | grep -oP 'id=\K[0-9]+')
if [ -n "$corne_id" ]; then
    setxkbmap -device "$corne_id" -layout de
fi
