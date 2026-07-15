local machine = require("machine")

_G.split_monitor_workspaces = nil
if machine.plugins and os.getenv("DOTFILES_VERIFY_CONFIG") ~= "1" then
	local runtime = os.getenv("XDG_RUNTIME_DIR")
	local instance = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
	local marker = runtime and instance and runtime .. "/hypr/" .. instance .. "/.started"
	local started = marker and io.open(marker)
	if started then
		started:close()
	end
	hl.on("hyprland.start", function()
		local file = marker and io.open(marker, "w")
		if file then
			file:close()
		end
	end)

	package.path = package.path
		.. ";"
		.. os.getenv("HOME")
		.. "/.config/hypr/plugins/split-monitor-workspaces/lua/?.lua"

	local ok, split = pcall(require, "split-monitor-workspaces")
	if ok then
		local monitor_priority = {}
		local seen = {}
		for _, monitor in ipairs({ machine.primary, machine.secondary }) do
			if monitor and not seen[monitor] then
				table.insert(monitor_priority, monitor)
				seen[monitor] = true
			end
		end

		_G.split_monitor_workspaces = split
		if started then
			split.setup({
				workspace_count = 5,
				monitor_priority = monitor_priority,
				keep_focused = true,
				enable_notifications = false,
				enable_persistent_workspaces = true,
				enable_wrapping = true,
			})
			hl.on("config.reloaded", split.grab_rogue_windows())
		end
	end
end

if hl.plugin.csgo_vulkan_fix then
	hl.plugin.csgo_vulkan_fix.vkfix_app({ app = "cs2", w = 1440, h = 1080 })
	hl.config({
		plugin = {
			csgo_vulkan_fix = {
				fix_mouse = true,
			},
		},
	})
end
