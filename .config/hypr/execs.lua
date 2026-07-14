local colors = require("matugen")
local machine = require("machine")

local function shell_quote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

hl.on("hyprland.start", function()
	hl.exec_cmd("swaync")
	hl.exec_cmd("awww-daemon &")
	-- hyprpolkitagent replaces the legacy polkit-gnome agent and ships a user service.
	hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
	-- GNOME Keyring is started/unlocked by SDDM's PAM integration and its user units.
	-- Hyprland already imports its session environment; Arch's dbus-broker shares systemd's environment.

	hl.exec_cmd("nm-applet &")
	hl.exec_cmd("blueman-applet &")
	hl.exec_cmd("waybar")

	hl.exec_cmd("swayosd-server &")
	hl.exec_cmd("vicinae server &")
	hl.exec_cmd("matugen image --source-color-index 0 " .. shell_quote(colors.image))
	hl.exec_cmd("hypridle")

	for _, cmd in ipairs(machine.autostart or {}) do
		hl.exec_cmd(cmd)
	end
end)
