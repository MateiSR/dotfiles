package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/dotfiles/?.lua"

package.loaded["machine"] = nil
local ok, machine = pcall(require, "machine")
if not ok or type(machine) ~= "table" then
	package.loaded["machine"] = {}
end

package.loaded["matugen"] = nil
if not pcall(require, "matugen") then
	-- fresh machine: matugen hasn't generated matugen.lua yet
	package.loaded["matugen"] = setmetatable({
		image = os.getenv("HOME") .. "/.config/hypr/shared/images/er-1.jpeg",
	}, {
		__index = function()
			return "#808080"
		end,
	})
end

local modules = {
	"vars",
	"general",
	"plugins",
	"env",
	"execs",
	"keybindings",
	"animations",
	"rules",
	"custom",
}

for _, module in ipairs(modules) do
	package.loaded[module] = nil
end

for _, module in ipairs(modules) do
	require(module)
end
