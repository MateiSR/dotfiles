## hyprland dotfiles

# dependencies
rofi swaybg swaync xdg-deskop-portal-hyprland ffnvcodec-headers mpvpaper nm-applet waybar polkit-gnome alacritty wlsunset gnome-keyring hyprwayland-scanner hypridle pamixer dunst kitty swayosd wlogout wl-clipboard wtype rofimoji luminance

# optional dependencies
jamesdsp 

# rofi config
See https://github.com/adi1090x/rofi?tab=readme-ov-file

# machine-specific config
Monitors, GPU vendor, plugins, input devices and per-machine autostart live in
`~/.config/dotfiles/machine.lua` (see `machine.lua.example`). Without it the
config boots with Hyprland's automatic monitor setup, no NVIDIA env vars and
no plugins.

# Workspaces
Without plugins, Hyprland's default numeric workspaces are used. `SUPER + 1`
through `SUPER + 5` switch workspaces, and adding `SHIFT` moves the active
window. With split-monitor-workspaces enabled, workspaces are per-monitor.

# hyprland plugins
Enabled per-machine via `machine.lua` (`plugins = true`)
- split-monitor-workspaces
- hyprexpo (https://github.com/hyprwm/hyprland-plugins)
