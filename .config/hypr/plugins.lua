local machine = require("machine")
local split = hl.plugin.split_monitor_workspaces

if machine.plugins and split then
	if machine.primary then
		split.max_workspaces({ monitor = machine.primary, max = 5 })
	end
	if machine.secondary then
		split.max_workspaces({ monitor = machine.secondary, max = 5 })
	end
	split.grab_rogue_windows()
end
