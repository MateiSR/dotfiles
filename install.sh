#!/usr/bin/env bash
set -euo pipefail
umask 022

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PACLIST_DIR="$ROOT/Paclists/Hyprland"
DRY_RUN=false
GPU=""
WITH_XORG=false
WITH_ARCHISO=false
WITH_OMF=true
TMP_ROOT=""

usage() {
	cat <<'EOF'
Usage: ./install.sh [options]

  --gpu amd|intel|nvidia  Install the matching graphics stack
  --with-xorg             Include the optional Xorg paclist
  --with-archiso          Include the optional ArchISO paclist
  --without-omf           Do not install or update Oh My Fish
  --dry-run               Print actions without changing anything
  -h, --help              Show this help
EOF
}

die() {
	printf 'error: %s\n' "$*" >&2
	exit 1
}

step() {
	printf '\n==> %s\n' "$*"
}

print_command() {
	printf '  '
	printf '%q ' "$@"
	printf '\n'
}

run() {
	print_command "$@"
	$DRY_RUN || "$@"
}

run_in() {
	local dir=$1
	shift
	printf '  cd %q && ' "$dir"
	printf '%q ' "$@"
	printf '\n'
	$DRY_RUN || (cd "$dir" && "$@")
}

update_checkout() {
	local repo=$1
	local dir=$2
	local branch=$3
	local origin

	if [[ -e "$dir" ]]; then
		[[ -d "$dir/.git" ]] || die "not a git checkout: $dir"
		[[ -z $(git -C "$dir" status --porcelain) ]] || die "checkout has local changes: $dir"
		origin=$(git -C "$dir" remote get-url origin)
		[[ ${origin%.git} == "${repo%.git}" ]] || die "unexpected origin in $dir: $origin"
		run git -C "$dir" remote set-branches --add origin "$branch"
		run git -C "$dir" fetch --prune origin
		if git -C "$dir" show-ref --verify --quiet "refs/heads/$branch"; then
			run git -C "$dir" switch "$branch"
		else
			run git -C "$dir" switch --track -c "$branch" "origin/$branch"
		fi
		run git -C "$dir" pull --ff-only origin "$branch"
	else
		run install -d "$(dirname "$dir")"
		run git clone --single-branch --branch "$branch" "$repo" "$dir"
	fi
}

hyprland_branch() {
	local version major minor
	if ! read -r _ version < <(pacman -Q hyprland 2>/dev/null); then
		$DRY_RUN && printf '%s\n' 'release/<installed-major.minor>.x' && return
		die "hyprland is not installed"
	fi
	version=${version#*:}
	version=${version%%-*}
	IFS=. read -r major minor _ <<< "$version"
	[[ $major =~ ^[0-9]+$ && $minor =~ ^[0-9]+$ ]] || die "cannot parse Hyprland version: $version"
	printf 'release/%s.%s.x\n' "$major" "$minor"
}

cleanup() {
	if [[ -n "$TMP_ROOT" && -d "$TMP_ROOT" ]]; then
		rm -rf -- "$TMP_ROOT"
	fi
}

while (($#)); do
	case $1 in
		--gpu)
			(($# >= 2)) || die "--gpu needs amd, intel, or nvidia"
			GPU=$2
			shift 2
			;;
		--with-xorg)
			WITH_XORG=true
			shift
			;;
		--with-archiso)
			WITH_ARCHISO=true
			shift
			;;
		--without-omf)
			WITH_OMF=false
			shift
			;;
		--dry-run)
			DRY_RUN=true
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*) die "unknown option: $1" ;;
	esac
done

case $GPU in
	""|amd|intel|nvidia) ;;
	*) die "unsupported GPU: $GPU" ;;
esac

((EUID != 0)) || die "run this as your user, not root"
command -v pacman >/dev/null || die "this installer requires Arch Linux"
if ! $DRY_RUN; then
	command -v sudo >/dev/null || die "sudo is required"
	TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-install.XXXXXXXX")
	trap cleanup EXIT
else
	TMP_ROOT="${TMPDIR:-/tmp}/dotfiles-install.dry-run"
fi

official_lists=(
	"$PACLIST_DIR/Apps_paclist.txt"
	"$PACLIST_DIR/Coding_paclist.txt"
	"$PACLIST_DIR/Fonts_paclist.txt"
	"$PACLIST_DIR/Hyprland_paclist.txt"
	"$PACLIST_DIR/MMedia_paclist.txt"
	"$PACLIST_DIR/Net_paclist.txt"
	"$PACLIST_DIR/Print_paclist.txt"
)

if [[ -n "$GPU" ]]; then
	official_lists+=("$PACLIST_DIR/Drivers_common_paclist.txt" "$PACLIST_DIR/Drivers_${GPU}_paclist.txt")
fi
$WITH_XORG && official_lists+=("$PACLIST_DIR/Xorg_paclist.txt")
$WITH_ARCHISO && official_lists+=("$PACLIST_DIR/ArchISO_paclist.txt")

for list in "${official_lists[@]}" "$PACLIST_DIR/AUR_paclist.txt"; do
	[[ -f "$list" ]] || die "missing paclist: $list"
done

mapfile -t OFFICIAL_PACKAGES < <(sort -u "${official_lists[@]}")
OFFICIAL_PACKAGES+=(base-devel git stow)
mapfile -t AUR_PACKAGES < <(sort -u "$PACLIST_DIR/AUR_paclist.txt")

step "Official packages"
run sudo pacman -Syu --needed "${OFFICIAL_PACKAGES[@]}"

step "paru and AUR packages"
if ! command -v paru >/dev/null; then
	run git clone https://aur.archlinux.org/paru.git "$TMP_ROOT/paru"
	run_in "$TMP_ROOT/paru" makepkg -si --needed
fi
run paru -S --needed paru "${AUR_PACKAGES[@]}"

step "Qogir cursor, Orchis GTK, and Tela icons"
run install -d "$HOME/.local/share/icons" "$HOME/.local/share/themes"
qogir_dir="$TMP_ROOT/qogir"
orchis_dir="$TMP_ROOT/orchis"
tela_dir="$TMP_ROOT/tela"
run git clone --depth 1 https://github.com/vinceliuice/Qogir-icon-theme.git "$qogir_dir"
run git clone --depth 1 https://github.com/vinceliuice/Orchis-theme.git "$orchis_dir"
run git clone --depth 1 https://github.com/vinceliuice/Tela-icon-theme.git "$tela_dir"
run rsync -a --delete "$qogir_dir/src/cursors/dist-Dark/" "$HOME/.local/share/icons/Qogir-white-cursors/"
run_in "$orchis_dir" ./install.sh -d "$HOME/.local/share/themes" -c dark -s compact
run_in "$tela_dir" ./install.sh -d "$HOME/.local/share/icons"

step "Dotfiles and Matugen"
run "$ROOT/bootstrap.sh"

step "Hyprland plugin"
hyprpm_output=$(hyprpm list 2>/dev/null || true)
if [[ $hyprpm_output != *"Repository hyprland-plugins"* ]]; then
	run hyprpm add https://github.com/hyprwm/hyprland-plugins
fi
run hyprpm update
run hyprpm enable csgo-vulkan-fix
HYPRLAND_LIVE=false
if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && hyprctl version >/dev/null 2>&1; then
	HYPRLAND_LIVE=true
	run hyprpm reload -n
fi

if $WITH_OMF; then
	step "Oh My Fish"
	OMF_PATH=${XDG_DATA_HOME:-$HOME/.local/share}/omf
	if [[ -f "$OMF_PATH/init.fish" ]]; then
		run fish -c 'omf update'
	else
		run curl --fail --location --output "$TMP_ROOT/install" https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install
		run curl --fail --location --output "$TMP_ROOT/install.sha256" https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install.sha256
		run_in "$TMP_ROOT" sha256sum -c install.sha256
		run fish "$TMP_ROOT/install" --noninteractive --yes
	fi
fi

step "SDDM Astronaut"
sddm_source_dir="$HOME/.local/share/dotfiles/sources/sddm-astronaut-theme"
sddm_theme_dir="/usr/share/sddm/themes/sddm-astronaut-theme"
sddm_state_dir="/var/lib/matugen-sddm"
update_checkout https://github.com/Keyitdev/sddm-astronaut-theme.git "$sddm_source_dir" master
run sudo install -d -o "$(id -u)" -g "$(id -g)" -m 0755 "$sddm_state_dir"
run sudo install -d -o root -g root -m 0755 "$sddm_theme_dir"
run sudo rsync -a --delete --exclude=.git/ --chown=root:root "$sddm_source_dir/" "$sddm_theme_dir/"
run sudo chmod -R a+rX "$sddm_theme_dir"
run sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/matugen.conf|' "$sddm_theme_dir/metadata.desktop"
run sudo ln -sfn "$sddm_state_dir/theme.conf" "$sddm_theme_dir/Themes/matugen.conf"
run sudo ln -sfn "$sddm_state_dir/wallpaper" "$sddm_theme_dir/Backgrounds/matugen-wallpaper"
run sudo install -Dm0644 "$ROOT/system/sddm/10-dotfiles-theme.conf" /etc/sddm.conf.d/10-dotfiles-theme.conf
run sudo install -Dm0644 "$ROOT/system/sddm/20-dotfiles-virtual-keyboard.conf" /etc/sddm.conf.d/20-dotfiles-virtual-keyboard.conf
run "$HOME/.config/dotfiles/scripts/update-sddm-theme.sh"

step "tmux plugins"
tpm_dir="$HOME/.tmux/plugins/tpm"
update_checkout https://github.com/tmux-plugins/tpm.git "$tpm_dir" master
run "$tpm_dir/bin/install_plugins"
run "$tpm_dir/bin/update_plugins" all

step "split-monitor-workspaces"
split_branch=$(hyprland_branch)
split_dir="$HOME/.config/hypr/plugins/split-monitor-workspaces"
update_checkout https://github.com/zjeffer/split-monitor-workspaces.git "$split_dir" "$split_branch"
$HYPRLAND_LIVE && run hyprctl reload

if ! $DRY_RUN; then
	step "Verification"
	# Vendored install.sh scripts and hyprpm can all exit 0 without installing.
	[[ -d "$HOME/.local/share/icons/Tela" && -d "$HOME/.local/share/icons/Tela-dark" ]] || die "Tela icons were not installed"
	[[ -d "$HOME/.local/share/themes/Orchis-Dark-Compact" ]] || die "Orchis-Dark-Compact was not installed"
	[[ $(hyprpm list) == *"Plugin csgo-vulkan-fix"* ]] || die "csgo-vulkan-fix was not installed"
	grep -Fxq 'ConfigFile=Themes/matugen.conf' "$sddm_theme_dir/metadata.desktop" || die "SDDM Matugen config is not selected"
	if $WITH_OMF; then
		fish -c 'type -q omf' || die "Oh My Fish was not installed"
	fi
	DOTFILES_VERIFY_CONFIG=1 Hyprland --verify-config -c "$HOME/.config/hypr/hyprland.lua"
	if $HYPRLAND_LIVE; then
		config_errors=$(hyprctl configerrors)
		[[ -z "$config_errors" ]] || die "Hyprland config errors: $config_errors"
	fi
fi

printf '\nDone.\n'
