## Hyprland dotfiles

Machine-specific monitors, GPU settings, input devices, workspace integration,
and autostart commands live in `~/.config/dotfiles/machine.lua`.

With `plugins = true`, `split-monitor-workspaces` provides five workspaces per
monitor. It is installed as a Lua package by `install.sh`, not through HyprPM.
Without it, the same bindings use Hyprland's normal numeric workspaces.

HyprPM manages only `csgo-vulkan-fix`.
