-- HOME-PC monitor + workspace layout (mirrors the sway/i3 overlays).
-- HDMI-A-1: main landscape display, DP-2: secondary portrait display.
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@100",
    position = "1080x528",
    scale    = 1,
})

hl.monitor({
    output    = "DP-2",
    mode      = "1920x1080@60",
    position  = "0x0",
    scale     = 1,
    transform = 3,
})

-- Pin workspaces 1-9 to the main display, 10 to the portrait display.
for i = 1, 9 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1" })
end

hl.workspace_rule({ workspace = "10", monitor = "DP-2" })

-- Spin down HDDs (i3 overlay: Mod4+Shift+p)
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("alacritty -e sudo hdparm -y /dev/sdb /dev/sdc /dev/sdd"))
