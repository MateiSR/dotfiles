#!/usr/bin/env bash
set -euo pipefail

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

ensure_symlink() {
	local target=$1
	local link=$2
	run install -d "$(dirname "$link")"
	if [[ -e "$link" && ! -L "$link" ]]; then
		die "refusing to replace non-symlink: $link"
	fi
	run ln -sfn "$target" "$link"
}

read_paclist() {
	local file=$1
	local array_name=$2
	local seen_name=$3
	local line package
	local -n packages=$array_name
	local -n seen=$seen_name

	[[ -f "$file" ]] || die "missing paclist: $file"
	while IFS= read -r line || [[ -n "$line" ]]; do
		line=${line%%#*}
		for package in $line; do
			if [[ -z ${seen[$package]+x} ]]; then
				packages+=("$package")
				seen[$package]=1
			fi
		done
	done < "$file"
}

clone_temp() {
	local url=$1
	local name=$2
	local result_name=$3
	local path="$TMP_ROOT/$name"
	local -n result=$result_name
	result=$path
	run git clone --depth 1 "$url" "$path"
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
		if $DRY_RUN; then
			run git -C "$dir" fetch --prune origin "$branch"
			run git -C "$dir" switch "$branch"
			run git -C "$dir" pull --ff-only origin "$branch"
			return
		fi
		git -C "$dir" remote set-branches --add origin "$branch"
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
	local package version major minor
	if ! read -r package version < <(pacman -Q hyprland 2>/dev/null); then
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

declare -a OFFICIAL_PACKAGES=()
declare -a AUR_PACKAGES=()
declare -A OFFICIAL_SEEN=()
declare -A AUR_SEEN=()

official_lists=(
	Apps_paclist.txt
	Coding_paclist.txt
	Fonts_paclist.txt
	Hyprland_paclist.txt
	MMedia_paclist.txt
	Net_paclist.txt
	Print_paclist.txt
)

for list in "${official_lists[@]}"; do
	read_paclist "$PACLIST_DIR/$list" OFFICIAL_PACKAGES OFFICIAL_SEEN
done

for package in base-devel git stow; do
	if [[ -z ${OFFICIAL_SEEN[$package]+x} ]]; then
		OFFICIAL_PACKAGES+=("$package")
		OFFICIAL_SEEN[$package]=1
	fi
done

if [[ -n "$GPU" ]]; then
	read_paclist "$PACLIST_DIR/Drivers_common_paclist.txt" OFFICIAL_PACKAGES OFFICIAL_SEEN
	read_paclist "$PACLIST_DIR/Drivers_${GPU}_paclist.txt" OFFICIAL_PACKAGES OFFICIAL_SEEN
fi
$WITH_XORG && read_paclist "$PACLIST_DIR/Xorg_paclist.txt" OFFICIAL_PACKAGES OFFICIAL_SEEN
$WITH_ARCHISO && read_paclist "$PACLIST_DIR/ArchISO_paclist.txt" OFFICIAL_PACKAGES OFFICIAL_SEEN
read_paclist "$PACLIST_DIR/AUR_paclist.txt" AUR_PACKAGES AUR_SEEN

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
clone_temp https://github.com/vinceliuice/Qogir-icon-theme.git qogir qogir_dir
clone_temp https://github.com/vinceliuice/Orchis-theme.git orchis orchis_dir
clone_temp https://github.com/vinceliuice/Tela-icon-theme.git tela tela_dir
run_in "$qogir_dir" ./install.sh -d "$HOME/.local/share/icons" -t default -c standard
run_in "$orchis_dir" ./install.sh -d "$HOME/.local/share/themes" -c dark -s compact
run_in "$tela_dir" ./install.sh -d "$HOME/.local/share/icons"

step "Dotfiles and Matugen"
run "$ROOT/bootstrap.sh"

orchis_theme="$HOME/.local/share/themes/Orchis-Dark-Compact/gtk-4.0"
ensure_symlink "$orchis_theme/gtk.css" "$HOME/.config/gtk-4.0/orchis.css"
ensure_symlink "$orchis_theme/assets" "$HOME/.config/gtk-4.0/assets"

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
	missing=$(pacman -T "${OFFICIAL_PACKAGES[@]}" paru "${AUR_PACKAGES[@]}" 2>/dev/null || true)
	[[ -z "$missing" ]] || die "missing packages: ${missing//$'\n'/ }"
	for command in fish Hyprland hyprpm matugen paru rsync sddm-greeter-qt6 stow vicinae; do
		command -v "$command" >/dev/null || die "missing command: $command"
	done
	[[ -d "$HOME/.local/share/icons/Qogir" ]] || die "Qogir was not installed"
	[[ -d "$HOME/.local/share/icons/Tela" ]] || die "Tela was not installed"
	[[ -d "$HOME/.local/share/icons/Tela-dark" ]] || die "Tela-dark was not installed"
	[[ -d "$HOME/.local/share/themes/Orchis-Dark-Compact" ]] || die "Orchis-Dark-Compact was not installed"
	[[ -L "$HOME/.config/gtk-4.0/orchis.css" ]] || die "missing GTK 4 Orchis link"
	[[ -L "$HOME/.config/gtk-4.0/assets" ]] || die "missing GTK 4 assets link"
	[[ $(git -C "$sddm_source_dir" branch --show-current) == master ]] || die "wrong SDDM Astronaut branch"
	[[ -L "$sddm_theme_dir/Themes/matugen.conf" ]] || die "missing SDDM Matugen config link"
	[[ -L "$sddm_theme_dir/Backgrounds/matugen-wallpaper" ]] || die "missing SDDM wallpaper link"
	[[ -f "$sddm_state_dir/theme.conf" ]] || die "missing generated SDDM config"
	[[ -f "$sddm_state_dir/wallpaper" ]] || die "missing generated SDDM wallpaper"
	grep -Fxq 'ConfigFile=Themes/matugen.conf' "$sddm_theme_dir/metadata.desktop" || die "SDDM Matugen config is not selected"
	[[ $(git -C "$split_dir" branch --show-current) == "$split_branch" ]] || die "wrong split-monitor-workspaces branch"
	[[ $(hyprpm list) == *"Plugin csgo-vulkan-fix"* ]] || die "csgo-vulkan-fix was not installed"
	[[ -x "$tpm_dir/tpm" ]] || die "TPM was not installed"
	if $WITH_OMF; then
		fish -c 'type -q omf' || die "Oh My Fish was not installed"
	fi
	Hyprland --verify-config -c "$HOME/.config/hypr/hyprland.lua"
	if $HYPRLAND_LIVE; then
		config_errors=$(hyprctl configerrors)
		[[ -z "$config_errors" ]] || die "Hyprland config errors: $config_errors"
	fi
fi

printf '\nDone.\n'
