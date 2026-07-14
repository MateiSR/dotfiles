local machine = require("machine")

_G.split_monitor_workspaces = nil
if machine.plugins then
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

		split.setup({
			workspace_count = 5,
			monitor_priority = monitor_priority,
			keep_focused = true,
			enable_notifications = false,
			enable_persistent_workspaces = true,
			enable_wrapping = true,
		})

		_G.split_monitor_workspaces = split
		hl.on("config.reloaded", split.grab_rogue_windows())
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
