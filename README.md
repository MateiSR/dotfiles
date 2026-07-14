# dotfiles

mateisr.com

## Install

```sh
git clone https://github.com/MateiSR/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh --gpu nvidia
```

Use `amd` or `intel` instead when appropriate. Omit `--gpu` to leave graphics
drivers alone.

The installer updates the system with the default paclists, bootstraps `paru`,
installs the AUR paclist, applies the dotfiles, and installs or updates:

- Qogir-white cursor, `Tela`/`Tela-dark` icons, and `Orchis-Dark-Compact`
- Matugen color overrides for GTK 3, GTK 4, and libadwaita apps
- `csgo-vulkan-fix` through HyprPM
- Oh My Fish and tmux plugins
- `split-monitor-workspaces` on the release branch matching Hyprland
- SDDM Astronaut from upstream Git with Matugen wallpaper/colors

It is safe to rerun after an update:

```sh
git pull --ff-only
./install.sh --gpu nvidia
```

Optional flags:

```text
--with-xorg
--with-archiso
--without-omf
--dry-run
```

The default official paclists are Apps, Coding, Fonts, Hyprland, Multimedia,
Network, and Print. The ArchISO and full Xorg lists are opt-in. Package commands
use `--needed` and keep pacman/paru confirmation prompts.

## Machine configuration

Edit the machine-local files created from the `.example` templates:

- `~/.config/dotfiles/machine.lua` — monitors, GPU, workspace integration,
  input devices, and per-machine autostart
- `~/.config/dotfiles/git.conf` — git identity
- `~/.config/dotfiles/scripts/gs_zipline_conf.sh` — Zipline upload key

`bootstrap.sh` can be run alone when only the Stow links and generated configs
need refreshing. New tracked files can be linked with:

```sh
stow --no-folding --compat -R -t "$HOME" .
```

Fonts are defined in `.config/matugen/keywords.json`.

## Desktop shell

The Hyprland session uses a small, composable shell rather than a full desktop
shell:

- Ironbar provides the three-island top bar, native system popups, and the
  launcher and power controls.
- SwayNC is the only notification daemon and owns the notification history,
  do-not-disturb state, and control center. Ironbar's bell is its controller,
  not a second notification implementation.
- SwayOSD displays volume, microphone, brightness, and lock-key feedback from
  the hardware bindings.
- Matugen generates the shared CSS palette for Ironbar, SwayNC, and SwayOSD.
  Ironbar and SwayNC reload after palette changes; SwayOSD reads the new
  palette on its next direct start.

All three processes are launched directly from `.config/hypr/execs.lua`; no
custom user services are installed. `Super+X` toggles the bar. The supplied
layouts live in `.config/ironbar`, `.config/swaync`, and `.config/swayosd`.

## SDDM

The installer updates
[sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme) from
upstream Git and configures its wallpaper and colors from Matugen. Theme code is
root-owned; generated files live in `/var/lib/matugen-sddm` and can be refreshed
without `sudo`.

Every `matugen image ...` run updates SDDM automatically. To reapply the last
generated theme or select a new wallpaper directly:

```sh
~/.config/dotfiles/scripts/update-sddm-theme.sh
~/.config/dotfiles/scripts/update-sddm-theme.sh /path/to/wallpaper
```

The installer does not enable a display manager. Enable SDDM for the next boot
when needed with `sudo systemctl enable sddm`.
