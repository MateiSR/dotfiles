# Vivaldi: Matugen colors

Matugen renders `.config/matugen/templates/vivaldi.css` to
`~/.config/vivaldi/mods/matugen.css`, a Vivaldi CSS mod that overrides the
theme engine's colors. The template is stowed with the rest of the dotfiles;
Vivaldi has to be pointed at the folder by hand once per profile.

## Install

1. Run `./bootstrap.sh` (or any `matugen image ...`) so `matugen.css` exists.
2. Open `vivaldi://experiments` and enable **Allow for using CSS modifications**.
3. Settings → Appearance → **Custom UI Modifications** → select
   `~/.config/vivaldi/mods`.
4. Pick a dark Vivaldi theme as the base, then restart Vivaldi.

## Notes

- Vivaldi reads CSS mods only at startup: restart after changing wallpaper.
- The mapping assumes Matugen's dark scheme.
- Vivaldi 8's unified UI draws the toolbar, panel strip and start page
  transparent over the window background, which the theme sets inline on
  `#browser`; the template overrides that background too.
- The template also hides the "Press Escape key to exit fullscreen." bubble
  (Vivaldi dropped its setting); other toasts in fullscreen go with it.
- Internal pages (settings, history) are themed, but they use Matugen's
  surface tones, which are only faintly tinted.
