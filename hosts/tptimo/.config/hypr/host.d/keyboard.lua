-- tptimo (laptop) keyboard layouts.
-- i3 mirrors this in ~/.config/i3/set-keyboard-layouts.sh.

-- Laptop keyboard: US layout. numlock_by_default is set in the base config.
-- Right Ctrl is Compose (i3: setxkbmap -option compose:rctrl): tap it, then
-- " + a → ä, ' + a → á, s + s → ß, etc. The Corne inherits the option and
-- keeps RAlt as AltGr.
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "compose:rctrl",
        kb_rules   = "",
    },
})

-- Corne: German layout (i3: setxkbmap -device <corne> -layout de).
-- `hyprctl devices` reports the device name lowercased with spaces as dashes.
hl.device({
    name      = "timos-corne-keyboard",
    kb_layout = "de",
})
