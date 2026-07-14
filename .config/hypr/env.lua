local machine = require("machine")

hl.env("XDG_SESSION_TYPE", "wayland")

if machine.gpu == "nvidia" then
	hl.env("LIBVA_DRIVER_NAME", "nvidia")
	hl.env("GBM_BACKEND", "nvidia-drm")
	hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
	hl.env("NVD_BACKEND", "direct")

	hl.config({
		cursor = {
			no_hardware_cursors = true,
		},
	})
end

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

hl.env("XCURSOR_THEME", "Qogir")
hl.env("XCURSOR_SIZE", "24")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
