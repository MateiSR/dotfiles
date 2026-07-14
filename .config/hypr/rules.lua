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
	name = "layerrule-wayfreeze",
	match = { namespace = "^(wayfreeze)$" },
	no_anim = true,
})

hl.layer_rule({
	name = "layerrule-slurp",
	match = { namespace = "^(slurp)$" },
	no_anim = true,
})

hl.window_rule({
	name = "cs2",
	match = { class = "^(cs2)$" },
	immediate = true,
	opacity = "1.0 override 1.0 override",
})

hl.window_rule({
	name = "libreoffice-writer-no-fullscreen",
	match = { class = "^(libreoffice-writer|soffice|Soffice)$" },
	fullscreen_state = "0 0",
	suppress_event = "fullscreen maximize fullscreenoutput",
})

hl.window_rule({
	name = "steam-games-fullscreen",
	match = { class = "^(steam_app_.*)$" },
	fullscreen = true,
})
