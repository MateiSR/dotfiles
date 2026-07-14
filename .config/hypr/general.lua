local colors = require("matugen")

hl.config({
	input = {
		sensitivity = -0.2,
		accel_profile = "flat",
	},

	-- render = {
	-- 	direct_scanout = 1,
	-- },

	general = {
		gaps_in = 4,
		gaps_out = 6,
		border_size = 1,
		resize_on_border = true,

		col = {
			inactive_border = colors.outline,
			active_border = colors.primary,
		},

		layout = "master",
		allow_tearing = true,
	},

	dwindle = {
		preserve_split = true,
		special_scale_factor = 0.8,
	},

	master = {
		new_on_top = false,
		mfact = 0.5,
	},

	misc = {
		vrr = 2,
		focus_on_activate = true,
		animate_manual_resizes = false,
		animate_mouse_windowdragging = false,
		enable_swallow = false,
		swallow_regex = "(foot|kitty|allacritty|Alacritty)",

		disable_hyprland_logo = true,
		force_default_wallpaper = 0,
		on_focus_under_fullscreen = 2,
		allow_session_lock_restore = true,

		initial_workspace_tracking = false,
	},

	debug = {
		vfr = true,
	},
})
