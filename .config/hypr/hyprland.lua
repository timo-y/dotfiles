-- Hyprland configuration (Lua API, Hyprland >= 0.57).
-- Mirrors ~/.config/i3/config; Wayland translations follow ~/.config/sway/config.
--
-- NOTE: Hyprland 0.57+ no longer reads ~/.config/hypr/hyprland.conf. The legacy
-- file is kept in this repo only for Hyprland builds that still parse hyprlang.

local mod      = "SUPER"
local terminal = "ghostty"
-- Ghostty's GTK4 Wayland IM can drop dead-key compose sequences (^, `); force
-- the simple compose-table IM. Same workaround as the sway config/`~/.xprofile`.
local function term(args)
    return "env GTK_IM_MODULE=gtk-im-context-simple " .. terminal .. " " .. args
end

-- Numpad keycodes (XKB / `xev` codes = evdev + 8), in KP_1..KP_9, KP_0 order.
-- i3 binds these as mod2+KP_1 (Num Lock on); the keysym approach breaks as
-- soon as Num Lock is off, because the numpad then reports KP_End/KP_Down/...
-- Bind by physical keycode instead — same fix as `bindcode` in the sway config.
--
-- A keycode bind still has to match the modmask exactly, and Num Lock adds
-- Mod2 to it, so each numpad bind is registered twice (with and without MOD2).
-- Whichever matches the current Num Lock state fires; the other never can.
local numpad_codes = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }

-- Host-specific monitor/workspace layout lives in hosts/<name>/.config/hypr/host.d/.
-- A machine without that overlay simply skips it (same no-op contract as the
-- `include host.d/*.conf` lines in the i3/sway configs).
local overlay = os.getenv("HOME") .. "/.config/hypr/host.d/display.lua"
local overlay_fh = io.open(overlay, "r")
if overlay_fh then
    overlay_fh:close()
    dofile(overlay)
end

-- ── Look and feel (i3: border pixel 1, no gaps, no effects) ─────────────────
hl.config({
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 1,                     -- i3: for_window [class=".*"] border pixel 1

        col = {
            active_border   = "rgb(2C78BF)", -- i3: client.focused child_border
            inactive_border = "rgb(3B3935)", -- i3: client.unfocused border
        },

        resize_on_border = true,
        layout           = "dwindle",
    },

    decoration = {
        rounding = 0,
        blur     = { enabled = false },
        shadow   = { enabled = false },
    },

    -- i3 has no animations; set enabled = true for Hyprland's default feel.
    animations = { enabled = false },

    -- Keeps the split direction sticky, like an i3 container split.
    dwindle = { preserve_split = true },

    misc = {
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,
    },

    input = {
        kb_layout  = "us", -- i3: US default on this laptop (tptimo)
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        -- i3 reaches the numpad with Mod4+mod2 (Num Lock on); mirror that.
        numlock_by_default = true,
        follow_mouse       = 0, -- i3: focus_follows_mouse no

        sensitivity = 0,
        touchpad    = { natural_scroll = false },
    },
})

-- Corne: German layout (i3: setxkbmap -device <corne> -layout de).
-- `hyprctl devices` reports the device name lowercased with spaces as dashes.
hl.device({
    name      = "timos-corne-keyboard",
    kb_layout = "de",
})

-- i3: new_float none — no border on floating windows.
hl.window_rule({
    name        = "no-border-floating",
    match       = { float = true },
    border_size = 0,
})

-- ── Window rules (i3: assign [class="..."]) ────────────────────────────────
hl.window_rule({ name = "ws3-browser", match = { class = ".*(brave|thorium).*" },        workspace = "3" })
hl.window_rule({ name = "ws4-discord", match = { class = ".*discord.*" },                workspace = "4" })
-- hl.window_rule({ name = "ws5-upnote", match = { class = ".*upnote.*" },               workspace = "5" })
hl.window_rule({ name = "ws5-mail",    match = { class = ".*(thunderbird|betterbird|mail).*" }, workspace = "5" })
hl.window_rule({ name = "ws6-games",   match = { class = ".*(heroic|steam).*" },         workspace = "6" })

-- ── Autostart ──────────────────────────────────────────────────────────────
hl.on("hyprland.start", function()
    -- Portals / session environment
    hl.exec_cmd("~/.config/hypr/xdg-portal-hyprland")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY XAUTHORITY")
    hl.exec_cmd("systemctl --user import-environment XDG_SESSION_TYPE XDG_SESSION_CLASS")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- i3: exec --no-startup-id dex --autostart --environment i3
    -- dex is not installed by setup.sh; uncomment after installing it.
    -- hl.exec_cmd("dex --autostart --environment hyprland")

    -- Optional session startup hook (skip cleanly if it does not exist).
    hl.exec_cmd("[ -f ~/.desktop-session/startup ] && bash ~/.desktop-session/startup")

    -- Bar (waybar stands in for i3bar/i3status-rs), notifications, tray.
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet --indicator")

    -- i3: exec_always feh --bg-fill ~/.config/hypr/background.jpg
    hl.exec_cmd("swaybg -m fill -i ~/.config/hypr/background.jpg")

    -- Screen lock (i3: xset s 3600 + xss-lock/i3lock — 1 hour idle).
    hl.exec_cmd("swayidle -w timeout 3600 'swaylock -f' before-sleep 'swaylock -f'")

    -- Applications, pinned to their workspaces like the i3 autostart block.
    hl.exec_cmd(term("-e tmux"), { workspace = 1, silent = true })
    hl.exec_cmd("brave",         { workspace = 3, silent = true })
    hl.exec_cmd("discord",       { workspace = 4, silent = true })
    hl.exec_cmd("betterbird",    { workspace = 5, silent = true })
    hl.exec_cmd("caffeine")

    -- Return to workspace 3 after startup (i3: i3-msg 'workspace 3').
    hl.timer(function()
        hl.dispatch(hl.dsp.focus({ workspace = 3 }))
    end, { timeout = 4000, type = "oneshot" })
end)

-- ── Terminal ───────────────────────────────────────────────────────────────
hl.bind(mod .. " + Return",       hl.dsp.exec_cmd(term("-e tmux")))
hl.bind(mod .. " + SHIFT + Return", hl.dsp.exec_cmd(term("-e nvim .")))

-- ── Kill focused window ────────────────────────────────────────────────────
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())

-- ── Program launcher (i3: dmenu_run; dmenu is X11-only, so wofi is the
-- Wayland equivalent — same run/drun split as the sway config) ─────────────
hl.bind(mod .. " + D", hl.dsp.exec_cmd("wofi --show run --define run-always_parse_args=true --exec-search"))
hl.bind(mod .. " + SHIFT + D", hl.dsp.exec_cmd("wofi --show drun"))

-- ── Focus (vim keys) ───────────────────────────────────────────────────────
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))

-- ── Move windows (vim keys) ────────────────────────────────────────────────
hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- ── Layout (i3: $mod+x tabbed/stacking, $mod+v split toggle) ───────────────
hl.bind(mod .. " + X",         hl.dsp.group.toggle())
hl.bind(mod .. " + V",         hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + V", hl.dsp.layout("togglesplit"))
-- i3's $mod+Shift+x (per-window border toggle) has no Hyprland equivalent:
-- borders are a single global setting here.
-- i3's $mod+space (focus mode_toggle) has no Hyprland equivalent either:
-- there is no tiling<->floating focus switch.

-- ── Fullscreen / floating ──────────────────────────────────────────────────
hl.bind(mod .. " + F",         hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

-- ── Reload / exit (i3: reload, restart, exit) ──────────────────────────────
hl.bind(mod .. " + SHIFT + C", hl.dsp.reload_config())
hl.bind(mod .. " + SHIFT + R", hl.dsp.reload_config()) -- no in-place restart
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())

-- ── Workspace switching / moving windows ───────────────────────────────────
for i = 1, 10 do
    local key = i % 10 -- workspace 10 lives on key 0
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Numpad workspace switching, matching the sway config's bindcode numbers.
for i, code in ipairs(numpad_codes) do
    hl.bind(mod .. " + code:" .. code,                hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + code:" .. code,        hl.dsp.window.move({ workspace = i }))

    -- Num Lock on: Mod2 is part of the modmask.
    hl.bind(mod .. " + MOD2 + code:" .. code,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + MOD2 + code:" .. code, hl.dsp.window.move({ workspace = i }))
end

-- i3: move workspace to output next (wrap around the monitor list).
hl.bind(mod .. " + SHIFT + N", function()
    local monitors = hl.get_monitors()
    local current  = hl.get_active_monitor()
    if not current or #monitors < 2 then
        return
    end

    local index = 1
    for i, monitor in ipairs(monitors) do
        if monitor.id == current.id then
            index = i
        end
    end

    local target = monitors[(index % #monitors) + 1]
    hl.dispatch(hl.dsp.workspace.move({ monitor = target.name }))
end)

-- ── Audio / brightness function keys (i3: pactl + brightnessctl) ───────────
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +10%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -10%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set +10%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), { locked = true, repeating = true })

-- ── Application launchers ──────────────────────────────────────────────────
hl.bind(mod .. " + B", hl.dsp.exec_cmd("brave"))
hl.bind(mod .. " + N", hl.dsp.exec_cmd("upnote"))
hl.bind(mod .. " + M", hl.dsp.exec_cmd("betterbird"))
hl.bind(mod .. " + A", hl.dsp.exec_cmd("pavucontrol"))

-- ── Screenshots ────────────────────────────────────────────────────────────
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("flameshot gui"))

-- ── Audio device switching ─────────────────────────────────────────────────
hl.bind(mod .. " + CTRL + N", hl.dsp.exec_cmd("pactl set-default-sink $(pactl list short sinks | grep -i 'usb' | head -n1 | cut -f2) && notify-send 'Audio' 'Switched to Headset'"))
hl.bind(mod .. " + CTRL + S", hl.dsp.exec_cmd("pactl set-default-sink $(pactl list short sinks | grep -i 'umc404hd' | head -n1 | cut -f2) && notify-send 'Audio' 'Switched to UMC404HD'"))

-- ── Prefer dark/light ──────────────────────────────────────────────────────
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"))
hl.bind(mod .. " + SHIFT + M", hl.dsp.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'"))

-- ── Mouse bindings (i3 leaves these commented out; kept for convenience) ───
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── window_movements submap (i3: mode "window_movements", $mod+r) ──────────
hl.define_submap("window_movements", function()
    hl.bind("H", hl.dsp.window.move({ direction = "left" }))
    hl.bind("J", hl.dsp.window.move({ direction = "down" }))
    hl.bind("K", hl.dsp.window.move({ direction = "up" }))
    hl.bind("L", hl.dsp.window.move({ direction = "right" }))

    for i, code in ipairs(numpad_codes) do
        hl.bind("code:" .. code,        hl.dsp.window.move({ workspace = i }))
        hl.bind("MOD2 + code:" .. code, hl.dsp.window.move({ workspace = i }))
    end

    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("Escape", hl.dsp.submap("reset"))
end)

hl.bind(mod .. " + R", hl.dsp.submap("window_movements"))
