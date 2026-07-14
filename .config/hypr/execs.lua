local colors = require("matugen")
local machine = require("machine")

local function shell_quote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

hl.on("hyprland.start", function()
	hl.exec_cmd("swaync")
	hl.exec_cmd("awww-daemon &")
	hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
	hl.exec_cmd("systemctl --user start gnome-keyring-daemon.service")

	hl.exec_cmd("swayosd-server &")
	hl.exec_cmd("vicinae server &")
	hl.exec_cmd("matugen image --source-color-index 0 " .. shell_quote(colors.image))
	hl.exec_cmd("ironbar")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprpm reload -n && hyprctl reload")

	for _, cmd in ipairs(machine.autostart or {}) do
		hl.exec_cmd(cmd)
	end
end)
