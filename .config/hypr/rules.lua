hl.window_rule({
    name = "windowrule-1",
    match = { class = "^(com.sidevesh.Luminance)$" },
    opacity = "0.8 0.8",
    float = true,
})

hl.window_rule({
    name = "windowrule-2",
    match = { class = "^(waypaper)$" },
    float = true,
})

hl.layer_rule({
    name = "layerrule-1",
    match = { namespace = "^(hyprfreeze)$" },
    no_anim = true,
})

hl.window_rule({
    name = "cs2-tearing",
    match = { class = "^(cs2)$" },
    immediate = true,
})

hl.window_rule({
    name = "cs2-opacity",
    match = { class = "^(cs2)$" },
    opacity = "1.0 override 1.0 override",
})

hl.window_rule({
    name = "steam-games-fullscreen",
    match = { class = "^(steam_app_.*)$" },
    fullscreen = true,
})
