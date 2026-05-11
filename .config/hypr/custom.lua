local vars = require("vars")

-- hl.monitor({
--     output = "",
--     mode = "preferred",
--     position = "auto",
--     scale = "1",
--     mirror = vars.monitor1,
-- })

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.device({
    name = "dualsense-wireless-controller-touchpad",
    enabled = false,
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
    decoration = {
        screen_shader = os.getenv("HOME") .. "/.config/hypr/shaders/custom.glsl",
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("xrandr --output " .. vars.monitor1 .. " --primary")
end)
