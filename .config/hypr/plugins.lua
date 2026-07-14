local vars = require("vars")
local split = hl.plugin.split_monitor_workspaces

if split then
    split.max_workspaces({ monitor = vars.monitor1, max = 5 })
    split.max_workspaces({ monitor = vars.monitor2, max = 5 })
    split.grab_rogue_windows()
end

-- hl.config({
--     plugin = {
--         csgo_vulkan_fix = {
--             fix_mouse = true,
--         },
--     },
-- })
--
-- hl.plugin.csgo_vulkan_fix.vkfix_app({ app = "cs2", w = 1440, h = 1080 })
