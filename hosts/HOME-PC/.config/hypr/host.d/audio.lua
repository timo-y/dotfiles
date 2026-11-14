-- HOME-PC audio device switching (i3/sway still keep these in their base
-- configs; the sinks below only exist on this desktop).
--
-- NOTE: the headset must be matched by its own name. A generic 'usb' grep also
-- matches the UMC404HD ('usb-BEHRINGER_UMC404HD...'), and head -n1 then picks
-- whichever sink sorts first, so the headset bind silently re-selected the UMC.
hl.bind("SUPER + CTRL + N", hl.dsp.exec_cmd("pactl set-default-sink $(pactl list short sinks | grep -i 'generalplus' | head -n1 | cut -f2) && notify-send 'Audio' 'Switched to Headset'"))
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("pactl set-default-sink $(pactl list short sinks | grep -i 'umc404hd' | head -n1 | cut -f2) && notify-send 'Audio' 'Switched to UMC404HD'"))
