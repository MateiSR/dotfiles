local colors = require("matugen")

local function shell_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

hl.on("hyprland.start", function()
    hl.exec_cmd("swaync")
    hl.exec_cmd("awww-daemon &")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    hl.exec_cmd("nm-applet &")
    hl.exec_cmd("blueman-applet &")
    hl.exec_cmd("waybar")
    hl.exec_cmd("wlsunset -S 09:00 -s 21:30")
    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("jamesdsp -t &")

    hl.exec_cmd("wpctl set-volume 87 1")
    hl.exec_cmd("swayosd-server &")
    hl.exec_cmd("vicinae server &")
    hl.exec_cmd("matugen image --source-color-index 0 " .. shell_quote(colors.image))
    hl.exec_cmd("hypridle")
end)
