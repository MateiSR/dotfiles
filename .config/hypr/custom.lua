local vars = require("vars")
local machine = require("machine")

for _, monitor in ipairs(machine.monitors or {}) do
	hl.monitor(monitor)
end

for _, name in ipairs(machine.disabled_devices or {}) do
	hl.device({
		name = name,
		enabled = false,
	})
end

if machine.primary and machine.secondary then
	hl.bind("ALT + TAB", hl.dsp.exec_cmd(vars.toggle_monitor .. " " .. machine.primary .. " " .. machine.secondary))
end

hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
})

if machine.screen_shader then
	hl.config({
		decoration = {
			screen_shader = machine.screen_shader,
		},
	})
end

hl.on("hyprland.start", function()
	if machine.primary then
		hl.exec_cmd("xrandr --output " .. machine.primary .. " --primary")
	end
end)
