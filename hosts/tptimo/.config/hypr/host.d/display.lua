-- tptimo (laptop) monitor layout.
--
-- Pin the scale to 1. The generated example config (which this overlay
-- replaces the monitor rule of) uses `scale = "auto"`, which derives a
-- fractional scale from the panel's physical DPI — on this 14" 1920x1200
-- panel that resolves to 1.5 and everything looks scaled up.
--
-- output = "" matches every output, so an external monitor stays at 1x too;
-- use the real name from `hyprctl monitors` instead if it ever needs its own
-- rule (mode/position/transform etc.).
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})
