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

- Qogir cursor, Tela Orange icons, and `Orchis-Dark-Compact`
- Matugen color overrides for GTK 3, GTK 4, and libadwaita apps
- `csgo-vulkan-fix` through HyprPM
- Oh My Fish and tmux plugins
- `split-monitor-workspaces` on the release branch matching Hyprland

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

The current SDDM theme is
[sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme) with a
modified wallpaper from `.config/dotfiles/wallpapers`.
