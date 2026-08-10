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
	-- The palette on disk is already current; awww just needs the image back.
	-- Its client fails fast when the daemon socket is missing, so poll for it.
	local restore = "for _ in $(seq 25); do awww query >/dev/null 2>&1 && break; sleep 0.2; done; "
		.. 'exec awww img --transition-type center "$1"'
	hl.exec_cmd("sh -c " .. shell_quote(restore) .. " awww " .. shell_quote(colors.image))
	hl.exec_cmd("ironbar")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprpm reload -n && hyprctl reload")

	for _, cmd in ipairs(machine.autostart or {}) do
		hl.exec_cmd(cmd)
	end
end)
