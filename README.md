# dotfiles
mateisr.com

## Setup

Configs are symlinked from this repo into `$HOME` with GNU stow (`--no-folding`,
so directories stay real and generated/secret files never enter the repo):

```sh
git clone https://github.com/MateiSR/dotfiles ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh
```

Then edit the machine-local files (gitignored; created from `.example` templates):
- `~/.config/dotfiles/machine.lua` — monitors, GPU vendor, plugins, input devices, per-machine autostart
- `~/.config/dotfiles/git.conf` — git identity (`[user]` block, included from `.gitconfig`)
- `~/.config/dotfiles/scripts/gs_zipline_conf.sh` — Zipline screenshot upload key

After adding a *new* file to the repo, re-run `stow --no-folding -R -t ~ .` to link it.
Fonts are defined once in `.config/matugen/keywords.json` (`{{custom.*}}` in templates).

vencord theme: https://discordstyles.github.io/DarkMatter/DarkMatter.theme.css



cursors: https://github.com/vinceliuice/Qogir-icon-theme


gtk: https://github.com/vinceliuice/Orchis-theme 
./install.sh -t orange -l --tweaks black, compact --color dark


icons: https://github.com/vinceliuice/Tela-icon-theme
./install.sh -c orange


change these using `nwg-look`


tmux: install TPM and `~/.tmux/plugins/tpm/bin/install_plugins`


sddm theme: currently using https://github.com/Keyitdev/sddm-astronaut-theme with a modified wallpaper (~/.config/hypr/shared/images)
