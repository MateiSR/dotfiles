local vars = require("vars")
local mod = vars.main_mod

-- Tracked alongside Hyprland's general.layout so J/K/O can dispatch
-- layout-appropriate actions without rebinding on toggle.
_G.current_layout = "master"

hl.bind(mod .. " + Q", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mod .. " + C", hl.dsp.window.close())
hl.bind(mod .. " + M", hl.dsp.exit())
hl.bind(mod .. " + E", hl.dsp.exec_cmd(vars.file_manager))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())

hl.bind(mod .. " + R", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("wlogout"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd(vars.rofi_brightness_launcher))
hl.bind(mod .. " + SEMICOLON", hl.dsp.exec_cmd("vicinae vicinae://extensions/vicinae/vicinae/search-emojis"))

hl.bind(mod .. " + W", hl.dsp.exec_cmd("waypaper"))
hl.bind(mod .. " + Z", hl.dsp.exec_cmd(vars.browser))

hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + J", function()
    hl.dispatch(_G.current_layout == "master"
        and hl.dsp.layout("cyclenext")
        or hl.dsp.window.cycle_next())
end)
hl.bind(mod .. " + K", function()
    hl.dispatch(_G.current_layout == "master"
        and hl.dsp.layout("cycleprev")
        or hl.dsp.window.cycle_next({ prev = true }))
end)
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + O", function()
    if _G.current_layout == "dwindle" then
        hl.dispatch(hl.dsp.layout("togglesplit"))
    end
end)

hl.bind(mod .. " + SHIFT + H", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))

hl.bind(mod .. " + V", function()
    local monitor = hl.get_active_monitor()
    if not monitor then
        return
    end

    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.resize({
        x = math.floor(monitor.width * 0.7),
        y = math.floor(monitor.height * 0.7),
        relative = false,
    }))
    hl.dispatch(hl.dsp.window.center())
end)

hl.bind(mod .. " + Space", function()
    _G.current_layout = _G.current_layout == "master" and "dwindle" or "master"
    hl.config({ general = { layout = _G.current_layout } })
    local label = _G.current_layout:sub(1, 1):upper() .. _G.current_layout:sub(2)
    hl.dispatch(hl.dsp.exec_cmd(
        "notify-send '" .. label .. " Layout' && sleep 0.5 && swaync-client --close-latest"
    ))
end)

local split = hl.plugin.split_monitor_workspaces
if split then
    hl.bind(mod .. " + CTRL + H", function()
        split.change_monitor_silent("prev")
    end)
    hl.bind(mod .. " + CTRL + L", function()
        split.change_monitor_silent("next")
    end)

    for i = 1, 5 do
        local workspace = i
        hl.bind(mod .. " + " .. workspace, function()
            split.workspace(workspace)
        end)
        hl.bind(mod .. " + SHIFT + " .. workspace, function()
            split.move_to_workspace_silent(workspace)
        end)
    end
else
    hl.bind(mod .. " + CTRL + H", hl.dsp.focus({ monitor = "l" }))
    hl.bind(mod .. " + CTRL + L", hl.dsp.focus({ monitor = "r" }))

    for i = 1, 5 do
        hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = "m~" .. i }))
        hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = "m~" .. i }))
    end
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(vars.mod .. " + SHIFT + ALT + bracketleft", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(vars.mod .. " + SHIFT + ALT + bracketright", hl.dsp.workspace.move({ monitor = "r" }))

hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

hl.bind("Print", hl.dsp.exec_cmd(vars.screenshot_script))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(vars.screenshot_script .. " --upload"))

hl.bind(mod .. " + GRAVE", hl.dsp.window.fullscreen_state({ internal = -1, client = 2 }))
hl.bind(mod .. " + Prior", hl.dsp.exec_cmd("~/.config/hypr/scripts/hyprgamelock.sh"))
hl.bind(mod .. " + END", hl.dsp.exec_cmd("~/.config/hypr/scripts/gamemode.sh"))

hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind(mod .. " + X", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

hl.bind("SUPER + A", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + A", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("qalculate-gtk"))
hl.bind("XF86ScreenSaver", hl.dsp.exec_cmd("hyprlock"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"))

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

hl.bind("Caps_Lock", hl.dsp.exec_cmd("swayosd-client --caps-lock"), { release = true })
