#!/bin/sh
# Re-apply LightDM/X11 keymap settings to the running Sway session.
#
# LightDM's Xsession wrapper applies /etc/X11/Xkbmap and ~/.Xkbmap with
# setxkbmap for X11 sessions. Sway reads XKB directly and never runs that
# wrapper, so options such as compose:ralt, compose:menu, or a non-default
# layout are lost after switching from i3.
#
# Translate the simple setxkbmap arguments used in ~/.Xkbmap into sway
# input commands. Unknown arguments (e.g. -device) are ignored.

set -eu

[ -n "${SWAYSOCK:-}" ] || exit 0

file="$HOME/.Xkbmap"
[ -r "$file" ] || exit 0

# Deliberately no eval: Xkbmap is only whitespace-separated setxkbmap args.
# shellcheck disable=SC2046
set -- $(cat "$file")

layout=''
model=''
variant=''
rules=''
options=''

while [ "$#" -gt 0 ]; do
    case "$1" in
        -layout|--layout)
            layout="${2:-}"
            shift 2 || shift
            ;;
        -model|--model)
            model="${2:-}"
            shift 2 || shift
            ;;
        -variant|--variant)
            variant="${2:-}"
            shift 2 || shift
            ;;
        -rules|--rules)
            rules="${2:-}"
            shift 2 || shift
            ;;
        -option|--option)
            if [ -n "${2:-}" ]; then
                options="${options:+$options,}$2"
            fi
            shift 2 || shift
            ;;
        *)
            shift
            ;;
    esac
done

apply() {
    swaymsg input type:keyboard "$@" >/dev/null 2>&1 || true
}

[ -n "$layout" ] && apply xkb_layout "$layout"
[ -n "$model" ] && apply xkb_model "$model"
[ -n "$variant" ] && apply xkb_variant "$variant"
[ -n "$rules" ] && apply xkb_rules "$rules"
[ -n "$options" ] && apply xkb_options "$options"

exit 0
